# 1. Python image istemal karein
FROM python:3.9-slim

# 2. Chrome aur zaroori tools install karein
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    unzip \
    curl \
    google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# 3. Flask aur Selenium install karein
RUN pip install flask selenium webdriver-manager gunicorn

# 4. App ka code yahan likhein (app.py ki zaroorat nahi, yahi file chalegi)
RUN echo 'from flask import Flask, request, jsonify \n\
from selenium import webdriver \n\
from selenium.webdriver.chrome.service import Service \n\
from selenium.webdriver.chrome.options import Options \n\
from webdriver_manager.chrome import ChromeDriverManager \n\
from selenium.webdriver.common.by import By \n\
from selenium.webdriver.common.keys import Keys \n\
import time, os \n\
\n\
app = Flask(__name__) \n\
\n\
def perform_like(user, pw, link): \n\
    opts = Options() \n\
    opts.add_argument("--headless") \n\
    opts.add_argument("--no-sandbox") \n\
    opts.add_argument("--disable-dev-shm-usage") \n\
    opts.binary_location = "/usr/bin/google-chrome" \n\
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=opts) \n\
    try: \n\
        driver.get("https://www.instagram.com/accounts/login/") \n\
        time.sleep(5) \n\
        driver.find_element(By.NAME, "username").send_keys(user) \n\
        driver.find_element(By.NAME, "password").send_keys(pw) \n\
        driver.find_element(By.NAME, "password").send_keys(Keys.ENTER) \n\
        time.sleep(8) \n\
        driver.get(link) \n\
        time.sleep(5) \n\
        driver.find_element(By.CSS_SELECTOR, "svg[aria-label=\"Like\"]").click() \n\
        return True \n\
    except: return False \n\
    finally: driver.quit() \n\
\n\
@app.route("/") \n\
def home(): return "Bot is Active!" \n\
\n\
@app.route("/like", methods=["POST"]) \n\
def like(): \n\
    data = request.json \n\
    if perform_like(data["username"], data["password"], data["url"]): \n\
        return {"status": "success"} \n\
    return {"status": "failed"} \n\
\n\
if __name__ == "__main__": \n\
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))' > app.py

# 5. Port open karein
EXPOSE 5000

# 6. App start karein
CMD ["python", "app.py"]
