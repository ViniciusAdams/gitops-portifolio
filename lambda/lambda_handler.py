import json
import random

# Simple list of Python trivia questions, dummy
QUESTIONS = [
    {"id": "q1", "q": "What keyword is used to define a function in Python?", "a": "def"},
    {"id": "q2", "q": "What is the output of len('hello')?", "a": "5"},
    {"id": "q3", "q": "Which data type stores an ordered, mutable sequence?", "a": "list"},
    {"id": "q4", "q": "What symbol starts a comment in Python?", "a": "#"},
    {"id": "q5", "q": "What will type(3.14) return?", "a": "float"},
]

def lambda_response(status_code, body):
    """Helper function to return consistent JSON responses."""
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body)
    }

def get_random_question():
    """Select and return a random question (without the answer)."""
    q = random.choice(QUESTIONS)
    return {"id": q["id"], "question": q["q"]}

def check_answer(event):
    """Check if the user’s answer matches the correct one."""
    try:
        data = json.loads(event.get("body", "{}"))
        qid = data.get("id")
        ans = (data.get("answer") or "").strip().lower()

        q = next((x for x in QUESTIONS if x["id"] == qid), None)
        if not q:
            return lambda_response(404, {"error": "Question not found"})

        correct = q["a"].strip().lower()
        return lambda_response(200, {"correct": ans == correct, "correct_answer": q["a"]})
    except Exception as e:
        return lambda_response(500, {"error": str(e)})

def handler(event, context):
    """Main Lambda entrypoint. Routes API requests to functions."""
    route = event.get("rawPath", "")
    method = event.get("requestContext", {}).get("http", {}).get("method", "")

    if method == "GET" and route == "/question":
        return lambda_response(200, get_random_question())
    elif method == "POST" and route == "/answer":
        return check_answer(event)
    else:
        return lambda_response(404, {"error": "Not found"})
