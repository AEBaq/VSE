/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : ble_usb_packet.sv
Author   : Yann Thoma
Date     : 28.11.2022

Context  : Lab for the verification of a BLE analyzer

********************************************************************************
Description : This file contains the definition of the output USB packets that
              shall be sent to the PC from the BLE analyzer.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   28.11.2022  YTA        Initial version

*******************************************************************************/


`ifndef BLE_USB_PACKET_SV
`define BLE_USB_PACKET_SV

class ble_usb_packet;

    byte size;
    byte rssi;
    bit[6:0] channel;
    bit isAdv;
    byte reserved; // Pas utilisé mais mis pour aligner les données
    byte addr[4];
    byte header[2];
    byte data[];


    // Fonction

    function string psprint();
        $sformat(psprint, "USB Packet, isAdv : %b, addr= %h, channel = %d, rssi = %d\nsize = %d, dataLength= %d\n",
                                                        this.isAdv, this.addr, this.channel, this.rssi, this.size,this.data.size());
    endfunction : psprint

    // Conversion en paquet USB, queue est la FIFO d'octets reçues
    function void from_bytes(const ref byte unsigned queue[$]); // pas sûre à 100% de const ref, mais ça me semblait le plus approrpié

        if (queue.size() < 10) begin
            `LOG_ERROR2(svlogger::getInstance(), "USB packet too small to be valid, size received =%d\n", queue.size());
            return;
        end

        // Dans l'ordre de reception des octets :
        size = queue[0];

        // Check que la taille du paquet correspond à la taille indiquée avant de continuer
        if (size != queue.size()) begin
            `LOG_WARNING3(svlogger::getInstance(), "USB size value %d is different from the received queue size %d\n", size, queue.size());
        end

        rssi = queue[1];
        channel = queue[2][7:1];
        isAdv = queue[2][0];
        reserved = queue[3];
        addr [0] = queue[4];
        addr [1] = queue[5];
        addr [2] = queue[6];
        addr [3] = queue[7];
        header[0] = queue[8];
        header[1] = queue[9];
        data = new[queue.size() - 10]; // On enlève les 10 premiers octets qui ne concernent pas les données
        for (int i = 10; i < queue.size(); i++) begin
            data[i - 10] = queue[i];
        end

    endfunction : from_bytes

    function bit is_valid(); // Vérifie que la taille du paquet est correcte, écrite en avance si nécessaire dans la suite du laboratoire
        return (size == (data.size() + 10));
    endfunction : is_valid

    function void set_size_from_values();
        size = 10 + data.size(); // 10 octets d'en-tête + taille des données
    endfunction : set_size_from_values

    function void build_from_ble_packet(ble_packet pkt);
        this.rssi = pkt.rssi;

        this.isAdv = pkt.isAdv;
        this.channel = pkt.channel;

        this.addr[0] = pkt.addr[7:0];
        this.addr[1] = pkt.addr[15:8];
        this.addr[2] = pkt.addr[23:16];
        this.addr[3] = pkt.addr[31:24];

        this.header[0] = pkt.header[7:0];
        this.header[1] = pkt.header[15:8];

        this.data = new[pkt.size];
        for (int i = 0; i < pkt.size; i++) begin
            this.data[i] = pkt.rawData[i * 8 +: 8];
        end
        this.set_size_from_values();
    endfunction : build_from_ble_packet

endclass : ble_usb_packet


typedef mailbox #(ble_usb_packet) usb_fifo_t;

`endif // BLE_USB_PACKET_SV
