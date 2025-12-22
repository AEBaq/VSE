/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : ble_usb_itf.sv
Author   : Yann Thoma
Date     : 28.11.2022

Context  : Lab for the verification of a BLE analyzer

********************************************************************************
Description : This file contains the definition of the USB interface for the
              BLE analyzer.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   28.11.2022  YTA        Initial version

*******************************************************************************/

`ifndef BLE_USB_ITF_SV
`define BLE_USB_ITF_SV

interface ble_usb_itf;
    logic clk_i;
    logic[7:0] data_o;
    logic valid_o;
	logic frame_o;
endinterface : ble_usb_itf

`endif // BLE_USB_ITF_SV
