main :: () {
   assert(enet_initialize() == 0, "Unable to setup enet!");
   defer enet_deinitialize();

   client := enet_host_create(null, 1, 2, 0, 0);
   assert(client != null, "Unable to create client!");
   defer enet_host_destroy(client);

   address: ENetAddress;

   enet_address_set_host(*address, "127.0.0.1");
   address.port = 7777;

   peer := enet_host_connect(client, *address, 2, 0);
   assert(peer != null, "No available peers!");

   event: ENetEvent;
   enet_host_service(client, *event, 5000);
   assert(event.type == .CONNECT, "Unable to connect to 127.0.0.1:7777!");

   // Send some events
   str    := "Hello, World!";
   packet := enet_packet_create(str.data, xx str.count, xx _ENetPacketFlag.ENET_PACKET_FLAG_RELIABLE);
   enet_packet_destroy(packet);

   print("Sending '%' to server...\n", str);
   enet_peer_send(peer, 0, packet);

   // Receive some events
   enet_host_service(client, *event, 2_000);

   // Disconnect the peer
   print("Disconnecting...\n");
   enet_peer_disconnect(peer, 0);

   disconnected := false;
   while enet_host_service(client, *event, 4_000) > 0 {
      if event.type == {
         case .RECEIVE;
            print("Received packet from host!\n");
            enet_packet_destroy(event.packet);

         case .DISCONNECT;
            print("Disconnect succeeded!\n");
            disconnected = true;
      }
   }

   if !disconnected then enet_peer_reset(peer);
}

#import "Basic";
#import,file "../module.jai";
