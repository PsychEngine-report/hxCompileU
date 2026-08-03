// Copyright (c) 2025 Andrés E. G.
//
// This software is licensed under the MIT License.
// See the LICENSE file for more details.

package src.utils;

import sys.net.Host;
import sys.net.Address;
import sys.net.UdpSocket;
import haxe.io.Bytes;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

import src.SlushiUtils;

using StringTools;

/**
 * A UDP server that listens for messages from the Wii U.
 * * Author: Slushi.
 */
class UDPListener {

	private static var UDP_PORT:Int = 4405;

	/**
	 * Starts the UDP listener.
	 */
	public static function start(?arg1:String):Void {
		if (arg1 != null && arg1 != "") {
			getPortFromLib(arg1);
		}
		var udpIp = "0.0.0.0";
		var udpPort:Int = UDP_PORT;
		var address:Address = new Address();
		var host = new Host(udpIp);

		address.host = host.ip;
		address.port = UDP_PORT;

		var socket = new UdpSocket();

		try {
			socket.bind(host, udpPort);
			SlushiUtils.printMsg('Listening in [$host:$udpPort] by UDP...', INFO);
			SlushiUtils.printMsg('------------------', NONE);

			while (true) {
				var arrayData = new Array<cpp.UInt8>();
				var data:Bytes = Bytes.alloc(1024);
				var address = socket.readFrom(data, 0, 1024, address);

				if (address != 0) {
					var clientIp = host;
					var clientPort = udpPort;

					var receivedString = data.toString();
					SlushiUtils.printMsg('$receivedString', NONE);
				}
			}
		} catch (e:Dynamic) {
			SlushiUtils.printMsg('------------------', NONE);
			SlushiUtils.printMsg('\nUnknown error: $e', ERROR);
		}

		SlushiUtils.printMsg('------------------', NONE);
		socket.close();
		SlushiUtils.printMsg('Socket closed', INFO);
	}

	/**
	 * Retrieves the port from a lib.
	 * @param lib 
	 */
	private static function getPortFromLib(lib:String):Void {
		var mainPath:String = "";
		var haxelibPath:String = Sys.getEnv("HAXEPATH") + "/lib";

		var localHaxelib = SlushiUtils.getPathFromCurrentTerminal() + "/.haxelib";
		if (FileSystem.exists(localHaxelib)) {
			mainPath = localHaxelib;
		} else {
			mainPath = haxelibPath;
		}

		if (!FileSystem.exists(mainPath + "/" + lib)) {
			SlushiUtils.printMsg("Lib [" + lib + "] not found", ERROR);
			return;
		}

		try {
			var hxuConfigPath:String = "";
			var currentFilePath = mainPath + "/" + lib + "/.current";
			
			if (FileSystem.exists(currentFilePath)) {
				var currentFile:String = File.getContent(currentFilePath).trim();
				if (currentFile == "git") {
					hxuConfigPath = mainPath + "/" + lib + "/git/HxCU_Meta.json";
				} else {
					hxuConfigPath = mainPath + "/" + lib + "/" + currentFile.replace(".", ",") + "/HxCU_Meta.json";
				}
			} else {
				// Fallback if .current doesn't exist, check git or common folders
				if (FileSystem.exists(mainPath + "/" + lib + "/git/HxCU_Meta.json")) {
					hxuConfigPath = mainPath + "/" + lib + "/git/HxCU_Meta.json";
				}
			}

			if (hxuConfigPath == "" || !FileSystem.exists(hxuConfigPath)) {
				SlushiUtils.printMsg("HxCU_Meta.json not found in [" + lib + "]", WARN);
				return;
			}

			var fileContent = File.getContent(hxuConfigPath);
			var jsonContent:Dynamic = Json.parse(fileContent);

			if (jsonContent.customUDPPort != null && Std.string(jsonContent.customUDPPort) != "") {
				UDP_PORT = Std.parseInt(jsonContent.customUDPPort);
				SlushiUtils.printMsg("UDP Port set to [" + UDP_PORT + "] from [" + lib + "]", INFO);
			}
		} catch (e) {
			return;
		}
	}
}
