package wan_project.simulations;

import inet.node.inet.StandardHost;
import inet.node.inet.Router;
import inet.node.ethernet.EthernetSwitch;
import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.visualizer.contract.IIntegratedVisualizer;
import ned.DatarateChannel;
import inet.linklayer.ppp.PppInterface;

network FourLAN
{
    @display("bgb=1200,600");

    types:
        channel LanLink extends DatarateChannel
        {
            datarate = 100Mbps;
            delay = 0.1ms;
        }
        channel WanLink extends DatarateChannel
        {
            datarate = 10Mbps;
            delay = 5ms;
        }

    submodules:
        configurator: Ipv4NetworkConfigurator;
        visualizer: <default("IntegratedCanvasVisualizer")> like IIntegratedVisualizer;

        // LAN1
        host1: StandardHost { @display("p=80,150"); }
        host2: StandardHost { @display("p=80,300"); }
        switch1: EthernetSwitch { @display("p=230,220"); }

        // Routers WAN
        router1: Router { @display("p=420,220"); }
        router2: Router { @display("p=620,220"); }

        // LAN2
        switch2: EthernetSwitch { @display("p=820,100"); }
        host3: StandardHost { @display("p=1000,60"); }
        host4: StandardHost { @display("p=1000,160"); }

        // LAN3
        switch3: EthernetSwitch { @display("p=820,340"); }
        host5: StandardHost { @display("p=1000,300"); }
        server: StandardHost { @display("p=1000,400"); }

    connections:
        // LAN1 → Router1
        host1.ethg++   <--> LanLink <--> switch1.ethg++;
        host2.ethg++   <--> LanLink <--> switch1.ethg++;
        switch1.ethg++ <--> LanLink <--> router1.ethg++;

        // WAN: R1 ↔ R2
        router1.pppg++ <--> WanLink <--> router2.pppg++;

        // R2 → LAN2 (switch2)
        router2.ethg++ <--> LanLink <--> switch2.ethg++;
        switch2.ethg++ <--> LanLink <--> host3.ethg++;
        switch2.ethg++ <--> LanLink <--> host4.ethg++;

        // R2 → LAN3 (switch3)
        router2.ethg++ <--> LanLink <--> switch3.ethg++;
        switch3.ethg++ <--> LanLink <--> host5.ethg++;
        switch3.ethg++ <--> LanLink <--> server.ethg++;
}
