main :: () {
   assert(enet_initialize() == 0, "Unable to setup enet!");
   defer enet_deinitialize();

   address: ENetAddress;
   address.port = 7777;

   server := enet_host_create(*address, 32, 2, 0, 0);
   assert(server != null, "Unable to create server!");
   defer enet_host_destroy(server);

   print("Started server...\n");

   // Block for 10sec waiting for an event
   event: ENetEvent;
   while enet_host_service(server, *event, 5_000) > 0 {
      if event.type == {
         case .CONNECT;
            print("A new client connected on port %\n", event.peer.address.port);
            // Store any relevant client info here
            event.peer.data = *"some client";

         case .RECEIVE;
            str: string;
            str.data  = event.packet.data;
            str.count = xx event.packet.dataLength;

            print("A packet of length % containing '%' was received from '%' on channel %\n",
               event.packet.dataLength,
               str,
               <<cast(*string)event.peer.data,
               event.channelID,
            );

            enet_packet_destroy(event.packet);

         case .DISCONNECT;
            print("'%' disconnected!\n", <<cast(*string)event.peer.data);
            event.peer.data = null; // Reset peer's client info

         case .DISCONNECT_TIMEOUT;
            print("% timed out!\n", event.peer.data);
            event.peer.data = null; // Reset peer's client info
      }
   }

   print("Closing server...\n");
}

#import "Basic";
#import,file "../module.jai";
