import os
import json
from pymongo import MongoClient

# Connessione a MongoDB Atlas tramite stringa memorizzata nelle variabili d'ambiente di AWS
MONGO_URI = os.environ.get("MONGO_URI", "mongodb+srv://test:test@cluster.mongodb.net/MyTEDsprintDB")
client = MongoClient(MONGO_URI)
db = client["MyTEDsprintDB"]
collection = db["tedsprintCollection"]

def lambda_handler(event, context):
    # 1. Lettura dell'ID inviato dall'app Flutter (tramite query string API Gateway)
    id_sorgente = None
    if event.get('queryStringParameters') and 'idx' in event['queryStringParameters']:
        id_sorgente = event['queryStringParameters']['idx']
        
    if not id_sorgente:
        return build_response(400, {"error": "Parametro 'idx' mancante"})

    try:
        # 2. Query Polimorfa: cerca l'ID sia come stringa sia come intero
        query_id = {"$or": [{"id": id_sorgente}, {"id": int(id_sorgente) if id_sorgente.isdigit() else id_sorgente}]}
        main_talk = collection.find_one(query_id)
        
        if not main_talk:
            return build_response(404, {"error": f"Talk con ID {id_sorgente} non trovato"})

        # Estrazione dei tag del video principale per l'algoritmo di Explainable UX
        main_tags = set(main_talk.get("all_tags", []))
        
        # 3. Costruzione dei 3 video correlati embedded
        recommendations = []
        # Cicliamo da 1 a 3 per mappare related_title_1, related_title_2, ecc.
        for i in range(1, 4):
            title_field = f"related_title_{i}"
            if title_field in main_talk and main_talk[title_field]:
                # Cerchiamo il video correlato nel DB per estrarre i suoi tag e calcolare l'affinità
                rel_title = main_talk[title_field]
                related_doc = collection.find_one({"title": rel_title})
                
                explanation = "Consigliato per affinità tematica."
                if related_doc:
                    related_tags = set(related_doc.get("all_tags", []))
                    # Intersezione matematica dei tag (Spiegazione logica per il prof)
                    common_tags = main_tags.intersection(related_tags)
                    if common_tags:
                        explanation = f"Consigliato perché parla di: {', '.join(list(common_tags)[:2])}"

                recommendations.append({
                    "related_title": rel_title,
                    "related_presenter": main_talk.get(f"related_presenter_{i}", "Autore sconosciuto"),
                    "related_duration": main_talk.get(f"related_duration_{i}", "0"),
                    "explanation": explanation
                })

        # Risposta finale strutturata
        payload = {
            "main_title": main_talk.get("title", "Talk sconosciuto"),
            "recommendations": recommendations
        }
        return build_response(200, payload)

    except Exception as e:
        return build_response(500, {"error": str(e)})

def build_response(status_code, body):
    # Genera la risposta includendo gli header CORS richiesti per la sicurezza
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",  # Abilita le chiamate dall'app Flutter
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }