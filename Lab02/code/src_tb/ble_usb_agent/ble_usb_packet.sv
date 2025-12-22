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

endclass : ble_usb_packet


typedef mailbox #(ble_usb_packet) usb_fifo_t;

`endif // BLE_USB_PACKET_SV
