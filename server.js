const WebSocket = require("ws");

const wss = new WebSocket.Server({ port: 8080 });

var connected_clients = {};
var matches = {};

const fs = require("fs");

//Cliente WebSocket
wss.on("connection", function connection(ws) {
  console.log("Um cliente se conectou");

  ws.id = getUniqueId();
  connected_clients[ws.id] = { ws: ws };

  ws.on("message", function incoming(message) {
    processMessage(JSON.parse(message), ws.id);
  });

  ws.on("close", function close() {
    console.log("Um cliente se desconectou");
  });
});

//Processamento de mensagens recebidas do cliente
function processMessage(message, sender_id) {
  if (message.type == "login") {
    //Verifica se os dados existem no arquivo e envia de vola a autorização de login
    checkLoginData(message.username, message.password, function (result) {
      if (result) {
        connected_clients[sender_id].username = message.username;
        let message_block = {
          type: message.type,
        };
        connected_clients[sender_id].ws.send(JSON.stringify(message_block));
        console.log("Login realizado, cliente: " + sender_id);
      }
    });
  } else if (message.type == "create_account") {
    //Verifica se o username já existe no arquivo, caso não exista, cria a conta, armazena no arquivo e envia a confimação de criação de conta
    verifyNewUserData(message.email, message.username, function (result) {
      if (!result) {
        let message_block = {
          type: message.type,
        };
        connected_clients[sender_id].ws.send(JSON.stringify(message_block));
        fs.appendFile(
          "login_data.txt",
          "\n" +
            message.email +
            " " +
            message.password +
            " " +
            message.username,
          function (err) {
            if (err) throw err;
            console.log("Cadastro realizado, cliente: " + sender_id);
          }
        );
      }
    });
  } else if (message.type == "chat") {
    //Recebe uma mensagem de um cliente e envia para os outros clientes para ser exibido no chat global
    Object.keys(connected_clients).forEach(function (id) {
      // Enviar a mensagem para cada cliente, exceto para o remetente
      if (id !== sender_id) {
        let message_block = {
          type: message.type,
          chat_message:
            "[ " +
            connected_clients[sender_id].username +
            " ]: " +
            message.chat_message,
        };
        connected_clients[id].ws.send(JSON.stringify(message_block));
      }
    });
  } else if (message.type == "create_match") {
    //Cria uma partida e envia para todos os clientes para ser exibido na lista de partidas
    matches[message.id] = { max_players: message.max_players };
    matches[message.id].players = [];

    Object.keys(connected_clients).forEach(function (id) {
      // Enviar a mensagem para todos os clientes
      let message_block = {
        type: message.type,
        id: message.id,
      };
      connected_clients[id].ws.send(JSON.stringify(message_block));
    });
    console.log("Partida criada - id = " + message.id);
  } else if (message.type == "match_entry") {
    //Adiciona SENDER à partida selecionada
    if (matches[message.id].max_players > 0) {
      matches[message.id].players.push(sender_id);
      matches[message.id].max_players--;
    }

    //Instancia SENDER como FPS e instancia as cenas Ally com os clientes já presentes na partida
    for (let i = 0; i < matches[message.id].players.length; i++) {
      if (sender_id == matches[message.id].players[i]) {
        message_block = {
          type: message.type,
          fps: true,
          id: i,
        };
        connected_clients[sender_id].ws.send(JSON.stringify(message_block));
      } else {
        message_block = {
          type: message.type,
          fps: false,
          id: i,
        };
        connected_clients[sender_id].ws.send(JSON.stringify(message_block));
      }
    }
    //Instancia o SENDER como Ally nos clientes já conectados
    var id = matches[message.id].players.length - 1;
    for (let i = 0; i < matches[message.id].players.length; i++) {
      if (sender_id != matches[message.id].players[i]) {
        message_block = {
          type: message.type,
          fps: false,
          id: id,
        };
        connected_clients[matches[message.id].players[i]].ws.send(
          JSON.stringify(message_block)
        );
      }
    }
  } else if (message.type == "position_update") {
    //Envia para os outros clientes da mesma partida a sua posição atualizada
    var sender_index = matches[message.match_id].players.indexOf(sender_id);
    for (let i = 0; i < matches[message.match_id].players.length; i++) {
      if (sender_id != matches[message.match_id].players[i]) {
        message_block = {
          type: message.type,
          transform: message.transform,
          head_transform: message.head_transform,
          id: sender_index,
        };
        connected_clients[matches[message.match_id].players[i]].ws.send(
          JSON.stringify(message_block)
        );
      }
    }
  } else if (message.type == "weapon_toggled") {
    //Envia para os outros clientes da mesma partida a sua arma atual
    var sender_index = matches[message.match_id].players.indexOf(sender_id);
    for (let i = 0; i < matches[message.match_id].players.length; i++) {
      if (sender_id != matches[message.match_id].players[i]) {
        message_block = {
          type: message.type,
          weapon_index: message.weapon_index,
          id: sender_index,
        };
        connected_clients[matches[message.match_id].players[i]].ws.send(
          JSON.stringify(message_block)
        );
      }
    }
  }
}

//Verificação dos dados de login/registro recebidos
function checkLoginData(client_username, client_password, callback) {
  fs.readFile("login_data.txt", function (err, data) {
    if (err) throw err;

    const row = data.toString().split("\n");
    for (let i = 0; i < row.length; i++) {
      var [email, username, password] = row[i].split(" ");

      console.log(row[i].split(" "));

      if (username === client_username && password === client_password) {
        callback(true);

        return;
      }
    }
    callback(false);
  });
}

function verifyNewUserData(client_email, client_username, callback) {
  fs.readFile("login_data.txt", function (err, data) {
    if (err) throw err;

    const row = data.toString().split("\n");
    for (let i = 0; i < row.length; i++) {
      var [email, username, password] = row[i].split(" ");

      if (username === client_username || email === client_email) {
        callback(true);

        return;
      }
    }
    callback(false);
  });
}

setInterval(() => {
  // Itera sobre cada partida no objeto matches
  for (let matchId in matches) {
    if (matches.hasOwnProperty(matchId)) {
      matches[matchId].players.forEach((player) => {
        message_block = {
          type: "enemy",
        };
        connected_clients[player].ws.send(JSON.stringify(message_block));
      });
    }
  }
}, 3000);

//Gera um identificador único para cada cliente
function getUniqueId() {
  function s() {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }
  return s() + s() + "-" + s();
}
