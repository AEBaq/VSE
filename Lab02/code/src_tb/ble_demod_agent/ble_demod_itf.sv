/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : ble_demod_itf.sv
Author   : Yann Thoma
Date     : 28.11.2022

Context  : Lab for the verification of a BLE analyzer

********************************************************************************
Description : This file contains the interface from the demodulator to the
              BLE analyzer

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   28.11.2022  YTA        Initial version

*******************************************************************************/

`ifndef BLE_DEMOD_ITF_SV
`define BLE_DEMOD_ITF_SV

interface ble_demod_itf;
    logic clk_i = 0;
    logic rst_i;
    logic serial_i;
    logic valid_i;
    logic[6:0] channel_i;
    logic[7:0] rssi_i;
endinterface : ble_demod_itf

`endif // BLE_DEMOD_ITF_SV
