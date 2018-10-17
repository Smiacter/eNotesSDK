/*
 * Copyright (C) 2014-2018 Advanced Card Systems Ltd. All rights reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "ABTBluetoothReader.h"

@class CBUUID;

/**
 * The <code>ABTAcr1255uj1Reader</code> class represents ACR1255U-J1 reader.
 * @author  Godfrey Chung
 * @version 1.1, 2 May 2018
 */
@interface ABTAcr1255uj1Reader : ABTBluetoothReader {

@protected
    CBUUID *_smartCardServiceUuid;
    CBUUID *_commandCharacteristicUuid;
    CBUUID *_responseCharacteristicUuid;
}

/**
 * Gets the battery level. When the Bluetooth reader returns the battery
 * level, it calls the
 * ABTBluetoothReaderDelegate::bluetoothReader:didChangeBatteryLevel:error:
 * method of its delegate object.
 * @return <code>YES</code> if the reader is attached, otherwise
 *         <code>NO</code>.
 */
- (BOOL)getBatteryLevel;

@end
