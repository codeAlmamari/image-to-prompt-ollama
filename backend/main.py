'''
FastAPI
→ the web framework (handles routes, requests, responses)

UploadFile, File
→ used to receive uploaded images from the browser

CORSMiddleware
→ allows your frontend (HTML) to call the backend (API)
→ without this, the browser blocks requests

JSONResponse
→ lets you return clean JSON error messages

base64
→ converts the image bytes into text
→ required because Ollama expects images as base64

requests
→ sends HTTP requests from Python to Ollama
'''

from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse 
import base64 
import requests
from PIL import Image
import io


'''
OLLAMA_URL
→ the Ollama API endpoint used to generate responses

MODEL_NAME
→ the vision model that understands images
→ LLaVA can see images + read instructions
'''
OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL_NAME = "llava:7b"

''' Creating backend Application '''
app = FastAPI()

''' To allow FrontEnd Call this API'''
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

PROMPT_INSTRUCTION = """
You are an expert prompt engineer. Describe the image as a generation prompt that can recreate it.
Return ONLY the prompt text (no markdown, no extra commentary).
Include:
- subject and key objects
- scene/setting and background
- composition (camera angle, framing)
- lighting
- colors
- style (photo/illustration/etc.)
- important details (text, materials, emotions)
Keep it concise but specific (2–6 lines max).
""".strip()

@app.post("/generate-prompt") 
async def generate_prompt(image: UploadFile = File(...)):
    try:
        ''' 
        Read the Uploaded Image:
        Browser sends the image as binary - Ollama requires images as base64 strings
           1. Read image bytes
           2. Convert bytes → base64 tex
        '''
        content = await image.read()
        # Resize to speed up (max 1024px)
        img = Image.open(io.BytesIO(content)).convert("RGB")
        img.thumbnail((1024, 1024))

        buf = io.BytesIO()
        img.save(buf, format="JPEG", quality=85)
        content = buf.getvalue()

        img_b64 = base64.b64encode(content).decode("utf-8")

        # Preparing Request for Ollama 
        payload = {
            "model": MODEL_NAME,
            "prompt": PROMPT_INSTRUCTION,
            "images": [img_b64],
            "stream": False,
            "options": {
                "temperature": 0.4
            }
        }

        '''
        1. Sends HTTP POST request to Ollama
        2. Ollama runs LLaVA on the image
        3. Returns JSON response
        4. raise_for_status() throws error if request fails
        '''
        r = requests.post(OLLAMA_URL, json=payload, timeout=300)
        r.raise_for_status()
        data = r.json()

        # Ollama returns {"response": "..."} for /api/generate
        result_text = (data.get("response") or "").strip()

        return {"prompt": result_text}

    except requests.exceptions.ConnectionError:
        return JSONResponse(
            status_code=503,
            content={"error": "Cannot reach Ollama. Make sure Ollama is running on http://localhost:11434"},
        )
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})
