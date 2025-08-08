# PROJECT_NAME Platform Context

## Architecture Overview
- **Frontend**: Next.js (port 3000) - User interface
- **Backend**: Express (port 3001) - API server  
- **Python API**: FastAPI (port 5000) - AI processing
- **RAG System**: FastAPI (port 8000) - Document processing

## Key Technologies
- Authentication: JWT with httpOnly cookies
- Database: MongoDB with Mongoose/Motor
- Vector DB: Pinecone
- Storage: AWS S3
- Queue: Agenda/Redis
- AI: OpenAI, Anthropic, Cohere

## Common Tasks
- Frontend: `npm run dev`
- Backend: `npm run dev`
- Python API: `python main.py`
- RAG: `python -m app.main`
