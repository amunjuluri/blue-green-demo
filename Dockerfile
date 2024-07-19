FROM node:14
WORKDIR /Users/anandmunjuluri/Desktop/7TH-SEM/DEVOPS/blue-green-demo
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD [ "node", "app.js" ]