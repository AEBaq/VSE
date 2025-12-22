/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : ble_packet.sv
Author   : Yann Thoma
Date     : 28.11.2022

Context  : Lab for the verification of a BLE analyzer

********************************************************************************
Description : This file contains the definition of the BLE packets in terms of
              a transaction.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   28.11.2022  YTA        Initial version

*******************************************************************************/

`ifndef BLE_PACKET_SV
`define BLE_PACKET_SV


class ble_packet;

    logic[(64*8+16+32+8):0] dataToSend;
    int sizeToSend;

    logic isAdv;
    logic dataValid = 1;
    rand logic[31:0] addr;
    rand logic[15:0] header;
    rand logic[(64*8):0] rawData;
    rand logic[5:0] size;
    rand logic[7:0] rssi;

    // Not sure this is totally right...
    constraint size_range {
      size inside {[6:10]};
    }


    function string psprint();
        $sformat(psprint, "BlePacket, isAdv : %b, addr= %h, time = %t\nsizeSend = %d, dataSend = %h\n",
                                                        this.isAdv, this.addr, $time,sizeToSend,dataToSend);
    endfunction : psprint

    function void post_randomize();

        logic[7:0] preamble=8'h55;

        // Initialisation des données à envoyer
        dataToSend = 0;
        sizeToSend=size*8+16+32+8;

        // Cas de l'envoi d'un paquet d'advertizing
        if (isAdv == 1) begin
            addr = 32'h12345678;
            // DeviceAddr = 0. Pour l'exemple
            for(int i = 0; i < 32; i++)
                rawData[size*8-1-i] = 0;
        end

        // Cas de l'envoi d'un paquet de données
        else if (isAdv == 0) begin
            // Peut-être que l'adresse devra être définie d'une certaine manière
            addr = 0;
        end


        // Affectation des données à envoyer
        for(int i = 0; i < 8; i++)
            dataToSend[sizeToSend-8+i]=preamble[i];

        for(int i = 0; i < 32; i++)
            dataToSend[sizeToSend-8-32+i]=addr[i];

        `LOG_INFO2(svlogger::getInstance(), "Sending packet with address %h\n",addr);

        for(int i = 0; i < 16; i++)
            dataToSend[sizeToSend-8-32-16+i]=0;

        for(int i = 0; i < 6; i++)
            dataToSend[sizeToSend-8-32-16+i]=size[i];

        for(int i = 0; i < size * 8; i++)
            dataToSend[sizeToSend-8-32-16-1-i]=rawData[size*8-1-i];

        if (isAdv) begin
            logic[31:0] ad;
            for(int i = 0; i < 32; i++)
                ad[i] = dataToSend[sizeToSend-8-32-16-32+i];
            `LOG_INFO2(svlogger::getInstance(), "Advertising with address %h\n",ad);
        end
    endfunction : post_randomize

endclass : ble_packet


typedef mailbox #(ble_packet) ble_fifo_t;

`endif // BLE_PACKET_SV
