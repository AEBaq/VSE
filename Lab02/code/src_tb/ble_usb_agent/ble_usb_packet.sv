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

    bit[7:0]    size;
    bit[7:0]    rssi;
    bit[6:0]    channel;
    bit         adv;
    bit[7:0]  reserved; // Pas utilisé mais mis pour aligner les données
    bit[31:0]   addr;
    bit[15:0]   header;
    bit[7:0]    data[];

    // Fonction

    function string psprint();
        $sformat(psprint, "USB Packet, isAdv : %b, addr= %h, channel = %d, rssi = %d\nsize = %d, dataLength= %d\n",
                                                        this.adv, this.addr, this.channel, this.rssi, this.size,this.data.size());
    endfunction : psprint

    // Conversion en paquet USB, queue est la FIFO d'octets reçues
    function void from_bytes(const ref byte unsigned queue[$]); // pas sûre à 100% de const ref, mais ça me semblait le plus approrpié

        if (queue.size() < 10) begin
            `LOG_ERROR(svlogger::getInstance(), "USB packet too small to be valid, size received =%d\n", queue.size());
            return;
        end

        // Dans l'ordre de reception des octets :
        size = queue[0];

        // Check que la taille du paquet correspond à la taille indiquée avant de continuer
        if (size != queue.size()) begin
            `LOG_WARNING(svlogger::getInstance(), "USB size value %d is different from the received queue size %d\n", size, queue.size());
        end

        rssi = queue[1];
        channel = queue[2][7:1];
        adv = queue[2][0];
        reserved = queue[3];
        addr = {queue[7], queue[6], queue[5], queue[4]};
        header = {queue[9], queue[8]};
        data = new[queue.size() - 10]; // On enlève les 10 premiers octets qui ne concernent pas les données
        for (int i = 10; i < queue.size(); i++) begin
            data[i - 10] = queue[i];
        end

    endfunction : from_bytes

    function bit is_valid(); // Vérifie que la taille du paquet est correcte, écrite en avance si nécessaire dans la suite du laboratoire
        return (size == (data.size() + 10));
    endfunction : is_valid

endclass : ble_usb_packet


typedef mailbox #(ble_usb_packet) usb_fifo_t;

`endif // BLE_USB_PACKET_SV
