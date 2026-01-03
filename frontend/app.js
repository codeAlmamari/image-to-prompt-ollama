// IMPORTANT: Use 127.0.0.1 to avoid IPv6 issues on Windows sometimes
const API_URL = "http://127.0.0.1:8000/generate-prompt";

const fileInput = document.getElementById("file");
const fileName = document.getElementById("fileName");
const btn = document.getElementById("btn");
const copyBtn = document.getElementById("copy");
const preview = document.getElementById("preview");
const out = document.getElementById("out");
const statusEl = document.getElementById("status");
const errEl = document.getElementById("err");
const dropzone = document.getElementById("dropzone");
const dropHint = document.getElementById("dropHint");
const toast = document.getElementById("toast");

let currentFile = null;

function showToast(msg){
  toast.textContent = msg;
  toast.classList.add("show");
  setTimeout(()=>toast.classList.remove("show"), 1600);
}

function setFile(file){
  currentFile = file;
  errEl.textContent = "";
  statusEl.textContent = "";
  out.value = "";
  copyBtn.disabled = true;

  if (!file){
    fileName.textContent = "No file selected";
    btn.disabled = true;
    preview.style.display = "none";
    dropHint.style.display = "block";
    preview.removeAttribute("src");
    return;
  }

  fileName.textContent = file.name;
  btn.disabled = false;

  preview.src = URL.createObjectURL(file);
  preview.style.display = "block";
  dropHint.style.display = "none";
}

// File picker
fileInput.addEventListener("change", () => {
  const f = fileInput.files?.[0] || null;
  setFile(f);
});

// Drag & drop (prevent default to allow dropping)
["dragenter","dragover"].forEach(evt=>{
  dropzone.addEventListener(evt, (e)=>{
    e.preventDefault();
    e.stopPropagation();
    dropzone.classList.add("drag");
  });
});
["dragleave","drop"].forEach(evt=>{
  dropzone.addEventListener(evt, (e)=>{
    e.preventDefault();
    e.stopPropagation();
    dropzone.classList.remove("drag");
  });
});

dropzone.addEventListener("drop", (e)=>{
  const f = e.dataTransfer.files?.[0];
  if (f) setFile(f);
});

// Generate prompt
btn.addEventListener("click", async () => {
  if (!currentFile) return;

  errEl.textContent = "";
  statusEl.innerHTML = `<span class="spinner"></span>Generating… (CPU may take a bit)`;
  btn.disabled = true;
  out.value = "";

  const fd = new FormData();
  fd.append("image", currentFile);

  try {
    const res = await fetch(API_URL, { method: "POST", body: fd });
    const data = await res.json();

    if (!res.ok) {
      throw new Error(data.error || "Request failed");
    }

    out.value = data.prompt || "";
    copyBtn.disabled = !out.value.trim();
    statusEl.textContent = "Done ✅";
    showToast("Prompt generated!");
  } catch (e) {
    errEl.textContent = String(e);
    statusEl.textContent = "";
    showToast("Failed. Check backend/ollama.");
  } finally {
    btn.disabled = !currentFile;
  }
});

// Copy prompt
copyBtn.addEventListener("click", async () => {
  try {
    await navigator.clipboard.writeText(out.value);
    showToast("Copied ✅");
  } catch {
    showToast("Copy failed");
  }
});
