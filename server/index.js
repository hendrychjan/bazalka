const denv = require("dotenv");
const net = require("net");
const serial = require("serialport");

denv.config({ path: ".env" });

let lastValue = 0;
let connections = [];

const netServer = net.createServer();

const serServer = new serial.SerialPort({
  path: process.env.SERIAL_PORT,
  baudRate: 9600,
});

serServer.on("open", () => {
  serServer.on("data", (d) => {
    const data = d.toString("utf-8");
    lastValue = data;
    process.stdout.write("[SERIAL]: " + data);
    connections.forEach((client) => {
      try {
        client.write(data);
      } catch (e) {}
    });
  });
});

netServer.on("connection", (socket) => {
  console.log("[INFO]: New client connected!");
  socket.write(lastValue);
  connections.push(socket);

  socket.on("data", (data) => {
    const value = data.toString("utf-8");
    console.log("[NET]: " + value);
    if (value === "update") {
      serServer.write("CM+STA\n");
      return;
    }
    if (value == "water_auto") {
      serServer.write("CM+WTA\n");
      return;
    }
    if (value == "pump_on") {
      serServer.write("CM+WTM\n");
      return;
    }
    if (value == "pump_off") {
      serServer.write("CM+HALT\n");
      return;
    }
  });
});

netServer.on("close", (socket) => {
  console.log("[INFO]: Client closed!");
  connections = connections.filter((client) => client !== socket);
});

netServer.on("disconnect", (socket) => {
  console.log("[INFO]: Client disconnected!");
  connections = connections.filter((client) => client !== socket);
});

netServer.listen(process.env.PORT, process.env.HOST, () => {
  console.log("[INFO]: Server started!");
});
