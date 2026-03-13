const express = require('express');
const app = express();
const http = require('http').Server(app);
const io = require('socket.io')(http);
const path = require('path');

app.use(express.json());
app.use(express.static('public'));

let timeLeft = 30; 
let nextResult = null;

// Game Loop
setInterval(() => {
    if (timeLeft > 0) {
        timeLeft--;
    } else {
        const result = nextResult || (Math.random() > 0.5 ? 'Red' : 'Green');
        io.emit('gameResult', { color: result });
        timeLeft = 30; 
        nextResult = null; 
    }
    io.emit('timer', timeLeft);
}, 1000);

// Admin API
app.post('/api/admin/set-result', (req, res) => {
    nextResult = req.body.color;
    res.json({ message: "Winner set to " + nextResult });
});

const PORT = process.env.PORT || 7860;
http.listen(PORT, '0.0.0.0', () => console.log('Live on ' + PORT));
