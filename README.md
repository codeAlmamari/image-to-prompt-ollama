# Image → Prompt (Ollama + LLaVA)

A simple **practice project** that converts any uploaded image into a reusable **AI image-generation prompt** using **Ollama + LLaVA**.

The idea is simple:
> Upload an image → analyze it with a vision model → generate a clean prompt you can reuse in any image generation AI (Stable Diffusion, Midjourney, etc.).

---

## Features
- Upload image or **drag & drop**
- Image **preview**
- Generate a high-quality **prompt**
- Copy prompt to clipboard
- Clean modern UI (HTML + CSS + JS)
- Local AI inference (no cloud, no API keys)
- CPU-friendly (with optional image resizing)

---

## Tech Stack
**Frontend**
- HTML
- CSS
- JavaScript

**Backend**
- Python
- FastAPI
- Uvicorn

**AI / Vision**
- Ollama
- LLaVA (`llava:7b`)

---

## Project Structure
- imgToPromp/
- backend/
- main.py
- requirements.txt
- .venv/ # created locally (ignored by git)
- frontend/
- index.html
- styles.css
- app.js
- start.bat
- stop.bat
- README.md

---

## ✅ Prerequisites
- Python 3.10+
- Git
- Ollama installed locally

---

## 1 Install Ollama & LLaVA

Install Ollama from the official installer, then pull the model:

```bash
ollama pull llava:7b
ollama list
```
---

## 2 Backend Setup (FastAPI)

Install Backend packages

```bash
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1   # Windows PowerShell
pip install -r requirements.txt
```
Run backend:
```bash
uvicorn main:app --reload --port 8000
```
Test:
```bash
http://127.0.0.1:8000/docs
```
---
## 3 Frontend Setup
Run Frontend:
```bash
cd frontend
python -m http.server 5500
```
Open in browser:
```bash
http://localhost:5500
```
---
## One-Click Run (Windows)
Start everything (Double click):
Start.bat

Stop everything (Double click):
Stop.bat
