---
title: NexQA Expert Engine
emoji: 🔍
colorFrom: blue
colorTo: purple
sdk: docker
pinned: false
license: mit
short_description: AI-powered wood quality inspection & paint color mixing API
---

# 🔍 NexQA Expert Engine

**AI-Powered Wood Quality Inspection & Smart Paint Lab**

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/` | Health check |
| `POST` | `/api/predict` | Wood defect detection (send image) |
| `GET` | `/api/history` | Inspection history |
| `POST` | `/api/color-recipe` | Paint color recipe generator |
| `GET` | `/api/color-history` | Color history |
| `POST` | `/api/signup` | Factory registration |
| `POST` | `/api/login` | Factory login |

## Environment Variables (Secrets)

Set these in Space Settings → Variables and secrets:

- `GEMINI_API_KEY` — Google Gemini API key

## Tech Stack

- Python 3.10 + Flask + Gunicorn
- YOLOv8 (`best.pt`) for defect detection
- Google Gemini for paint recipe generation
- SQLite (persistent in `/app/instance/`)
