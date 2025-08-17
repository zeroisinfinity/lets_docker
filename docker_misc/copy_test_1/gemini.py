import google.generativeai as genai

# Set your API key here
genai.configure(api_key="AIzaSyDO49qFCilfsrO7wGxFRXk9v0MQ_-H63PM")

# Use the free, fast model
model = genai.GenerativeModel("models/gemini-1.5-flash")
que = input("Enter the query - ")
while que:
    response = model.generate_content(que)
    print(response.text)
    que = input("Enter the query - ")


