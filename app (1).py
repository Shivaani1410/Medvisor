import os
import json
import requests
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
import PyPDF2
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import re
import logging
from datetime import datetime
import warnings
from io import BytesIO
from typing import List, Dict, Any

warnings.filterwarnings("ignore")

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})  # Allow all origins for mobile access

# Increase max file size to 16MB
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024

class MedicalRAGSystem:
    def __init__(self):
        """Initialize the Medical RAG System with free APIs"""
        
        # Initialize sentence transformer for embeddings (free)
        logger.info("Loading embedding model...")
        try:
            self.embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
            logger.info("Embedding model loaded successfully!")
        except Exception as e:
            logger.error(f"Failed to load embedding model: {e}")
            raise
        
        # Initialize medical knowledge base
        self.medical_knowledge = self._load_medical_knowledge()
        self.knowledge_embeddings = self._create_knowledge_embeddings()
        
        # API configurations (all free)
        self.medical_api_url = "https://api.fda.gov/drug/label.json"
        
        logger.info("Medical RAG System initialized successfully!")
    
    def _load_medical_knowledge(self) -> List[Dict]:
        """Load comprehensive medical knowledge base"""
        return [
            {
                "condition": "Diabetes Type 2",
                "symptoms": ["elevated glucose", "high HbA1c", "polyuria", "polydipsia", "weight loss"],
                "lab_ranges": {"glucose": ">126 mg/dL", "hba1c": ">6.5%"},
                "description": "Chronic metabolic disorder characterized by insulin resistance and elevated blood glucose levels"
            },
            {
                "condition": "Hypertension",
                "symptoms": ["elevated blood pressure", "headache", "dizziness", "chest pain"],
                "lab_ranges": {"systolic_bp": ">140 mmHg", "diastolic_bp": ">90 mmHg"},
                "description": "Persistently elevated arterial blood pressure affecting cardiovascular system"
            },
            {
                "condition": "Hyperlipidemia",
                "symptoms": ["high cholesterol", "elevated triglycerides", "chest pain", "xanthomas"],
                "lab_ranges": {"total_cholesterol": ">240 mg/dL", "ldl": ">160 mg/dL", "triglycerides": ">200 mg/dL"},
                "description": "Abnormally elevated levels of lipids in the blood"
            },
            {
                "condition": "Anemia",
                "symptoms": ["low hemoglobin", "fatigue", "weakness", "pale skin", "shortness of breath"],
                "lab_ranges": {"hemoglobin_male": "<13.5 g/dL", "hemoglobin_female": "<12 g/dL", "hematocrit": "<36%"},
                "description": "Condition characterized by insufficient healthy red blood cells or hemoglobin"
            },
            {
                "condition": "Thyroid Dysfunction",
                "symptoms": ["abnormal TSH", "weight changes", "fatigue", "temperature sensitivity"],
                "lab_ranges": {"tsh_high": ">4.5 mIU/L", "tsh_low": "<0.5 mIU/L"},
                "description": "Disorders affecting thyroid hormone production and regulation"
            },
            {
                "condition": "Kidney Disease",
                "symptoms": ["elevated creatinine", "proteinuria", "edema", "hypertension"],
                "lab_ranges": {"creatinine": ">1.2 mg/dL", "bun": ">20 mg/dL", "egfr": "<60 mL/min/1.73m²"},
                "description": "Chronic condition affecting kidney function and waste filtration"
            },
            {
                "condition": "Liver Disease",
                "symptoms": ["elevated ALT", "elevated AST", "jaundice", "abdominal pain"],
                "lab_ranges": {"alt": ">40 U/L", "ast": ">40 U/L", "bilirubin": ">1.2 mg/dL"},
                "description": "Conditions affecting liver function and metabolism"
            },
            {
                "condition": "Cardiovascular Disease",
                "symptoms": ["chest pain", "elevated troponin", "abnormal ECG", "shortness of breath"],
                "lab_ranges": {"troponin": ">0.04 ng/mL", "ck_mb": ">6.3 ng/mL"},
                "description": "Diseases affecting the heart and blood vessels"
            }
        ]
    
    def _create_knowledge_embeddings(self) -> np.ndarray:
        """Create embeddings for medical knowledge base"""
        logger.info("Creating knowledge embeddings...")
        texts = []
        for item in self.medical_knowledge:
            text = f"{item['condition']} {' '.join(item['symptoms'])} {item['description']}"
            texts.append(text)
        
        embeddings = self.embedding_model.encode(texts)
        return np.array(embeddings)
    
    def extract_text_from_pdf(self, pdf_file) -> str:
        """Extract text from uploaded PDF file with proper resource management"""
        pdf_reader = None
        try:
            # Read file content into BytesIO for better handling
            pdf_bytes = pdf_file.read()
            pdf_stream = BytesIO(pdf_bytes)
            
            # Create PDF reader
            pdf_reader = PyPDF2.PdfReader(pdf_stream)
            text = ""
            
            # Extract text from all pages
            for page_num, page in enumerate(pdf_reader.pages):
                try:
                    page_text = page.extract_text()
                    if page_text:
                        text += page_text + "\n"
                except Exception as page_error:
                    logger.warning(f"Error extracting text from page {page_num}: {page_error}")
                    continue
            
            # Close the stream
            pdf_stream.close()
            
            if not text.strip():
                logger.warning("No text extracted from PDF")
                return ""
            
            logger.info(f"Successfully extracted {len(text)} characters from PDF")
            return text
            
        except Exception as e:
            logger.error(f"Error extracting PDF text: {str(e)}")
            return ""
        finally:
            # Ensure stream is closed
            try:
                if 'pdf_stream' in locals():
                    pdf_stream.close()
            except:
                pass
    
    def extract_medical_values(self, text: str) -> Dict[str, Any]:
        """Extract medical values and lab results from text using regex"""
        medical_values = {}
        
        # Common medical patterns (more flexible)
        patterns = {
            'glucose': r'(?:glucose|blood\s*sugar)[:\s]*(\d+\.?\d*)\s*(?:mg/dl|mg%)?',
            'hba1c': r'(?:hba1c|glycated\s*hemoglobin)[:\s]*(\d+\.?\d*)\s*%?',
            'cholesterol': r'(?:total\s*)?cholesterol[:\s]*(\d+\.?\d*)\s*(?:mg/dl)?',
            'hdl': r'hdl[:\s]*(\d+\.?\d*)\s*(?:mg/dl)?',
            'ldl': r'ldl[:\s]*(\d+\.?\d*)\s*(?:mg/dl)?',
            'triglycerides': r'triglycerides[:\s]*(\d+\.?\d*)\s*(?:mg/dl)?',
            'hemoglobin': r'(?:hemoglobin|hb)[:\s]*(\d+\.?\d*)\s*(?:g/dl|gm%)?',
            'hematocrit': r'hematocrit[:\s]*(\d+\.?\d*)\s*%?',
            'creatinine': r'creatinine[:\s]*(\d+\.?\d*)\s*(?:mg/dl)?',
            'bun': r'(?:bun|blood\s*urea\s*nitrogen)[:\s]*(\d+\.?\d*)\s*(?:mg/dl)?',
            'alt': r'(?:alt|sgpt)[:\s]*(\d+\.?\d*)\s*(?:u/l|iu/l)?',
            'ast': r'(?:ast|sgot)[:\s]*(\d+\.?\d*)\s*(?:u/l|iu/l)?',
            'tsh': r'tsh[:\s]*(\d+\.?\d*)\s*(?:miu/l|µiu/ml)?',
            'blood_pressure': r'(?:bp|blood\s*pressure)[:\s]*(\d+)\s*/\s*(\d+)',
            'temperature': r'(?:temp|temperature)[:\s]*(\d+\.?\d*)',
            'wbc': r'(?:wbc|white\s*blood\s*cell)[:\s]*(\d+\.?\d*)\s*(?:cells/µl)?',
            'platelet': r'platelet[:\s]*(\d+\.?\d*)\s*(?:cells/µl)?'
        }
        
        text_lower = text.lower()
        
        for key, pattern in patterns.items():
            matches = re.findall(pattern, text_lower, re.IGNORECASE)
            if matches:
                if key == 'blood_pressure':
                    medical_values['systolic_bp'] = float(matches[0][0])
                    medical_values['diastolic_bp'] = float(matches[0][1])
                else:
                    # Take the first match
                    medical_values[key] = float(matches[0])
        
        logger.info(f"Extracted {len(medical_values)} medical values")
        return medical_values
    
    def search_medical_database(self, query: str) -> Dict[str, Any]:
        """Search external medical databases (FDA API - free)"""
        try:
            # Clean and format query
            query_clean = query.replace(" ", "+")
            fda_url = f"https://api.fda.gov/drug/label.json?search=description:{query_clean}&limit=2"
            
            response = requests.get(fda_url, timeout=10)
            if response.status_code == 200:
                data = response.json()
                results = data.get("results", [])
                
                # Extract relevant information
                simplified_results = []
                for result in results[:2]:
                    simplified_results.append({
                        "drug_name": result.get("openfda", {}).get("brand_name", ["Unknown"])[0],
                        "generic_name": result.get("openfda", {}).get("generic_name", ["Unknown"])[0],
                        "manufacturer": result.get("openfda", {}).get("manufacturer_name", ["Unknown"])[0]
                    })
                
                return {
                    "source": "FDA Database",
                    "results": simplified_results,
                    "status": "success"
                }
        except Exception as e:
            logger.error(f"Error searching medical database: {str(e)}")
        
        return {"source": "FDA Database", "results": [], "status": "error"}
    
    def _generate_structured_analysis(self, medical_values: Dict) -> str:
        """Generate structured medical analysis based on extracted values"""
        analysis = "## Medical Analysis Report\n\n"
        
        # Analyze each value
        concerns = []
        recommendations = []
        normal_findings = []
        
        # Glucose analysis
        if 'glucose' in medical_values:
            glucose = medical_values['glucose']
            if glucose > 126:
                concerns.append(f"⚠️ Elevated fasting glucose level ({glucose} mg/dL) - indicates diabetes")
                recommendations.append("Consult endocrinologist for diabetes management and HbA1c testing")
            elif glucose > 100:
                concerns.append(f"⚠️ Pre-diabetic glucose level ({glucose} mg/dL)")
                recommendations.append("Lifestyle modifications: diet control, regular exercise, weight management")
            else:
                normal_findings.append(f"✓ Normal glucose level ({glucose} mg/dL)")
        
        # HbA1c analysis
        if 'hba1c' in medical_values:
            hba1c = medical_values['hba1c']
            if hba1c > 6.5:
                concerns.append(f"⚠️ High HbA1c ({hba1c}%) confirms diabetes")
                recommendations.append("Intensive diabetes management required")
            elif hba1c > 5.7:
                concerns.append(f"⚠️ Pre-diabetic HbA1c ({hba1c}%)")
            else:
                normal_findings.append(f"✓ Normal HbA1c ({hba1c}%)")
        
        # Cholesterol analysis
        if 'cholesterol' in medical_values:
            cholesterol = medical_values['cholesterol']
            if cholesterol > 240:
                concerns.append(f"⚠️ High total cholesterol ({cholesterol} mg/dL) - cardiovascular risk")
                recommendations.append("Lipid panel review, consider statin therapy, dietary modifications")
            elif cholesterol > 200:
                concerns.append(f"⚠️ Borderline high cholesterol ({cholesterol} mg/dL)")
                recommendations.append("Heart-healthy diet, reduce saturated fats")
            else:
                normal_findings.append(f"✓ Normal cholesterol ({cholesterol} mg/dL)")
        
        # Blood Pressure analysis
        if 'systolic_bp' in medical_values:
            systolic = medical_values['systolic_bp']
            diastolic = medical_values.get('diastolic_bp', 0)
            if systolic > 140 or diastolic > 90:
                concerns.append(f"⚠️ Hypertension detected (BP: {systolic}/{diastolic} mmHg)")
                recommendations.append("Blood pressure management: medication review, reduce sodium, stress management")
            elif systolic > 120 or diastolic > 80:
                concerns.append(f"⚠️ Elevated blood pressure ({systolic}/{diastolic} mmHg)")
                recommendations.append("Monitor blood pressure regularly, lifestyle modifications")
            else:
                normal_findings.append(f"✓ Normal blood pressure ({systolic}/{diastolic} mmHg)")
        
        # Hemoglobin analysis
        if 'hemoglobin' in medical_values:
            hgb = medical_values['hemoglobin']
            if hgb < 12:
                concerns.append(f"⚠️ Low hemoglobin ({hgb} g/dL) - indicates anemia")
                recommendations.append("Iron supplementation, complete blood count, investigate cause")
            elif hgb > 17:
                concerns.append(f"⚠️ High hemoglobin ({hgb} g/dL)")
                recommendations.append("Further investigation for polycythemia")
            else:
                normal_findings.append(f"✓ Normal hemoglobin ({hgb} g/dL)")
        
        # Liver function
        if 'alt' in medical_values:
            alt = medical_values['alt']
            if alt > 40:
                concerns.append(f"⚠️ Elevated ALT ({alt} U/L) - possible liver dysfunction")
                recommendations.append("Liver function tests, avoid alcohol, hepatologist consultation")
            else:
                normal_findings.append(f"✓ Normal ALT ({alt} U/L)")
        
        if 'ast' in medical_values:
            ast = medical_values['ast']
            if ast > 40:
                concerns.append(f"⚠️ Elevated AST ({ast} U/L)")
            else:
                normal_findings.append(f"✓ Normal AST ({ast} U/L)")
        
        # Kidney function
        if 'creatinine' in medical_values:
            creat = medical_values['creatinine']
            if creat > 1.2:
                concerns.append(f"⚠️ Elevated creatinine ({creat} mg/dL) - kidney function concern")
                recommendations.append("Kidney function assessment, eGFR calculation, nephrology referral")
            else:
                normal_findings.append(f"✓ Normal creatinine ({creat} mg/dL)")
        
        # Thyroid function
        if 'tsh' in medical_values:
            tsh = medical_values['tsh']
            if tsh > 4.5:
                concerns.append(f"⚠️ High TSH ({tsh} mIU/L) - hypothyroidism suspected")
                recommendations.append("Thyroid panel (T3, T4), endocrinology consultation")
            elif tsh < 0.5:
                concerns.append(f"⚠️ Low TSH ({tsh} mIU/L) - hyperthyroidism suspected")
                recommendations.append("Complete thyroid function tests, endocrinology referral")
            else:
                normal_findings.append(f"✓ Normal TSH ({tsh} mIU/L)")
        
        # Build analysis report
        if normal_findings:
            analysis += "### ✓ Normal Findings:\n"
            for finding in normal_findings:
                analysis += f"{finding}\n"
            analysis += "\n"
        
        if concerns:
            analysis += "### ⚠️ Areas of Concern:\n"
            for concern in concerns:
                analysis += f"{concern}\n"
            analysis += "\n"
        
        if recommendations:
            analysis += "### 📋 Recommendations:\n"
            for i, rec in enumerate(recommendations, 1):
                analysis += f"{i}. {rec}\n"
            analysis += "\n"
        
        # Risk Assessment
        analysis += "### 🎯 Risk Assessment:\n"
        risk_level = "LOW"
        risk_color = "🟢"
        
        if len(concerns) >= 4:
            risk_level = "HIGH"
            risk_color = "🔴"
        elif len(concerns) >= 2:
            risk_level = "MODERATE"
            risk_color = "🟡"
        
        analysis += f"{risk_color} Overall Risk Level: **{risk_level}**\n\n"
        
        # Additional recommendations
        analysis += "### 💡 General Recommendations:\n"
        analysis += "- Schedule a follow-up consultation with your healthcare provider\n"
        analysis += "- Maintain a healthy lifestyle: balanced diet, regular exercise, adequate sleep\n"
        analysis += "- Keep track of your vital signs and lab results\n"
        analysis += "- Take prescribed medications as directed\n\n"
        
        analysis += "---\n"
        analysis += "*⚠️ DISCLAIMER: This is an AI-generated analysis for informational purposes only. "
        analysis += "It is NOT a substitute for professional medical advice, diagnosis, or treatment. "
        analysis += "Always consult qualified healthcare professionals for proper medical evaluation and care.*"
        
        return analysis
    
    def find_similar_conditions(self, report_text: str, top_k: int = 3) -> List[Dict]:
        """Find similar medical conditions using vector similarity"""
        try:
            # Create embedding for the report
            report_embedding = self.embedding_model.encode([report_text])
            
            # Calculate similarities
            similarities = cosine_similarity(report_embedding, self.knowledge_embeddings)[0]
            
            # Get top k similar conditions
            top_indices = np.argsort(similarities)[-top_k:][::-1]
            
            similar_conditions = []
            for idx in top_indices:
                condition = self.medical_knowledge[idx].copy()
                condition['similarity_score'] = float(similarities[idx])
                similar_conditions.append(condition)
            
            return similar_conditions
        except Exception as e:
            logger.error(f"Error finding similar conditions: {e}")
            return []
    
    def comprehensive_analysis(self, report_text: str, medical_values: Dict) -> Dict[str, Any]:
        """Perform comprehensive RAG analysis"""
        
        # 1. Vector similarity search
        similar_conditions = self.find_similar_conditions(report_text)
        
        # 2. External database search
        primary_condition = similar_conditions[0]['condition'] if similar_conditions else "general health"
        external_data = self.search_medical_database(primary_condition)
        
        # 3. Generate structured analysis
        detailed_analysis = self._generate_structured_analysis(medical_values)
        
        # 4. Generate summary
        summary = self._generate_summary(similar_conditions, medical_values)
        
        # 5. Compile comprehensive report
        comprehensive_report = {
            "timestamp": datetime.now().isoformat(),
            "extracted_values": medical_values,
            "predicted_conditions": similar_conditions,
            "external_research": external_data,
            "detailed_analysis": detailed_analysis,
            "summary": summary,
            "report_preview": report_text[:500] + "..." if len(report_text) > 500 else report_text
        }
        
        return comprehensive_report
    
    def _generate_summary(self, conditions: List[Dict], values: Dict) -> str:
        """Generate executive summary"""
        if not conditions:
            return "Analysis based on extracted lab values. No specific condition pattern strongly matches the available data."
        
        primary_condition = conditions[0]
        confidence = primary_condition['similarity_score']
        
        summary = f"**Primary Predicted Condition:** {primary_condition['condition']}\n"
        summary += f"**Confidence Score:** {confidence:.1%}\n\n"
        summary += f"**Description:** {primary_condition['description']}\n\n"
        
        if len(values) > 0:
            summary += f"**Lab Values Analyzed:** {len(values)} parameters\n\n"
        
        if len(conditions) > 1:
            summary += "**Alternative Considerations:**\n"
            for condition in conditions[1:]:
                summary += f"- {condition['condition']} (Match: {condition['similarity_score']:.1%})\n"
        
        return summary

# Initialize RAG system
logger.info("Initializing Medical RAG System...")
rag_system = MedicalRAGSystem()

@app.route('/', methods=['GET'])
def home():
    """Home endpoint"""
    return jsonify({
        "service": "Medical RAG Analysis System",
        "version": "2.0.0",
        "status": "running",
        "endpoints": {
            "health": "/health",
            "analyze": "/analyze-report",
            "search": "/search-conditions",
            "research": "/external-research",
            "knowledge": "/knowledge-base"
        },
        "supported_formats": ["PDF", "TXT"],
        "max_file_size": "16MB"
    })

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "service": "Medical RAG System",
        "version": "2.0.0",
        "timestamp": datetime.now().isoformat(),
        "system_ready": True
    })

@app.route('/analyze-report', methods=['POST'])
def analyze_medical_report():
    """Main endpoint for medical report analysis"""
    try:
        logger.info("Received analysis request")
        
        # Check if file is uploaded
        if 'file' not in request.files:
            logger.warning("No file in request")
            return jsonify({
                "error": "No file uploaded",
                "status": "error"
            }), 400
        
        file = request.files['file']
        if file.filename == '':
            logger.warning("Empty filename")
            return jsonify({
                "error": "No file selected",
                "status": "error"
            }), 400
        
        logger.info(f"Processing file: {file.filename}")
        
        # Extract text based on file type
        report_text = ""
        
        if file.filename.lower().endswith('.pdf'):
            logger.info("Extracting text from PDF...")
            report_text = rag_system.extract_text_from_pdf(file)
        elif file.filename.lower().endswith(('.txt', '.text')):
            logger.info("Reading text file...")
            report_text = file.read().decode('utf-8', errors='ignore')
        else:
            return jsonify({
                "error": f"Unsupported file format. Please upload PDF or TXT files only.",
                "status": "error"
            }), 400
        
        if not report_text.strip():
            logger.warning("No text extracted from file")
            return jsonify({
                "error": "Could not extract text from file. Please ensure the file contains readable text.",
                "status": "error"
            }), 400
        
        logger.info(f"Extracted {len(report_text)} characters from file")
        
        # Extract medical values
        logger.info("Extracting medical values...")
        medical_values = rag_system.extract_medical_values(report_text)
        
        if not medical_values:
            logger.warning("No medical values found in text")
            return jsonify({
                "error": "No medical values detected in the report. Please ensure the report contains lab results with values.",
                "status": "error",
                "hint": "The report should contain values like: Glucose: 120 mg/dL, Cholesterol: 200 mg/dL, etc."
            }), 400
        
        # Perform comprehensive RAG analysis
        logger.info("Performing comprehensive analysis...")
        analysis_result = rag_system.comprehensive_analysis(report_text, medical_values)
        
        logger.info("Analysis completed successfully")
        return jsonify({
            "status": "success",
            "message": "Medical report analyzed successfully",
            "data": analysis_result
        })
    
    except Exception as e:
        logger.error(f"Error analyzing report: {str(e)}", exc_info=True)
        return jsonify({
            "error": f"Analysis failed: {str(e)}",
            "status": "error",
            "details": "Please check if the file is a valid PDF or text file with medical lab results"
        }), 500

@app.route('/search-conditions', methods=['POST'])
def search_conditions():
    """Search for medical conditions"""
    try:
        data = request.get_json()
        query = data.get('query', '')
        
        if not query:
            return jsonify({
                "error": "Query parameter required",
                "status": "error"
            }), 400
        
        # Find similar conditions
        similar_conditions = rag_system.find_similar_conditions(query, top_k=5)
        
        return jsonify({
            "status": "success",
            "query": query,
            "results": similar_conditions
        })
    
    except Exception as e:
        logger.error(f"Error searching conditions: {str(e)}")
        return jsonify({
            "error": f"Search failed: {str(e)}",
            "status": "error"
        }), 500

@app.route('/external-research', methods=['POST'])
def external_research():
    """Get external medical research"""
    try:
        data = request.get_json()
        condition = data.get('condition', '')
        
        if not condition:
            return jsonify({
                "error": "Condition parameter required",
                "status": "error"
            }), 400
        
        # Search external databases
        research_data = rag_system.search_medical_database(condition)
        
        return jsonify({
            "status": "success",
            "condition": condition,
            "research": research_data
        })
    
    except Exception as e:
        logger.error(f"Error fetching research: {str(e)}")
        return jsonify({
            "error": f"Research fetch failed: {str(e)}",
            "status": "error"
        }), 500

@app.route('/knowledge-base', methods=['GET'])
def get_knowledge_base():
    """Get the medical knowledge base"""
    return jsonify({
        "status": "success",
        "knowledge_base": rag_system.medical_knowledge,
        "total_conditions": len(rag_system.medical_knowledge)
    })

@app.errorhandler(413)
def too_large(e):
    return jsonify({
        "error": "File too large. Maximum file size is 16MB",
        "status": "error"
    }), 413

@app.errorhandler(500)
def internal_error(e):
    logger.error(f"Internal server error: {str(e)}")
    return jsonify({
        "error": "Internal server error",
        "status": "error"
    }), 500

if __name__ == '__main__':
    print("\n" + "="*60)
    print("🚀 MEDICAL RAG ANALYSIS SYSTEM")
    print("="*60)
    print("\n📊 Features Enabled:")
    print("   ✅ PDF Processing (PyPDF2)")
    print("   ✅ Text File Processing")
    print("   ✅ Vector Embeddings (Sentence Transformers)")
    print("   ✅ Medical Knowledge Base (8 conditions)")
    print("   ✅ External Database Integration (FDA API)")
    print("   ✅ Comprehensive Health Analysis")
    print("   ✅ Risk Assessment")
    
    print("\n🌐 Server Configuration:")
    print("   Host: 0.0.0.0 (accessible from network)")
    print("   Port: 5000")
    print("   Max File Size: 16MB")
    print("   CORS: Enabled (all origins)")
    
    print("\n📡 Available Endpoints:")
    print("   GET  /           - API information")
    print("   GET  /health     - Health check")
    print("   POST /analyze-report  - Analyze medical report (PDF/TXT)")
    print("   POST /search-conditions - Search medical conditions")
    print("   POST /external-research - Get external research")
    print("   GET  /knowledge-base - View knowledge base")
    
    print("\n💡 To connect from mobile:")
    print("   1. Make sure your phone and computer are on the same WiFi")
    print("   2. Find your computer's IP address:")
    print("      - Windows: ipconfig")
    print("      - Mac/Linux: ifconfig or ip addr")
    print("   3. In your app, use: http://YOUR_IP:5000/analyze-report")
    print("   4. Example: http://192.168.1.100:5000/analyze-report")
    
    print("\n" + "="*60)
    print("🏥 Starting server...")
    print("="*60 + "\n")
    
    # Run the Flask app
    app.run(debug=True, host='0.0.0.0', port=5000, threaded=True)