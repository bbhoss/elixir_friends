import {Socket} from "phoenix"
let socket = new Socket("/ws")
socket.connect()
let chan = socket.chan("tweets")
chan.join().receive("ok", chan => {
  console.log(`Subscribed to tweets`)
})
chan.on("tweet", function(msg) {
    console.log(msg)
    $('#tweets').prepend(msg.view);
})
let App = {}
export default App
