# 1. In dein git-dev Verzeichnis wechseln (oder neu anlegen)
mkdir -p ~/git-dev/aprs-meshcom-analyse && cd ~/git-dev/aprs-meshcom-analyse

# 2. Kopiere den Textinhalt unserer Expertenanalyse hier aus dem Editor
# und speichere ihn ab als: README.md

# 3. Git initialisieren und committen
git init
git branch -M main
git add README.md
git commit -m "docs: Expertenanalyse zu APRS und MeshCom 4.0 (DK5EN v4.40a)"

# 4. Mit deinem GitHub Repository verknüpfen und hochladen
git remote add origin https://github.com/DEIN-USERNAME/DEIN-REPO-NAME.git
git push -u origin main