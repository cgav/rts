PREF=/opt/gnat/bin/

sim:
	export PATH=$PATH:$PREF

	sed "s/with Digital_IO; use Digital_IO;/with Digital_IO_Sim; use Digital_IO_Sim;/g" robot_monitor.adb > tmp1234.adb
	mv tmp1234.adb robot_monitor.adb

	sed "s/with Digital_IO; use Digital_IO;/with Digital_IO_Sim; use Digital_IO_Sim;/g" robot_interface.adb > tmp1234.adb
	mv tmp1234.adb robot_interface.adb

	gnatmake -I/opt/win_io hanoi.adb `/opt/gtkada/bin/gtkada-config`

real:
	export PATH=$PATH:$PREF

	sed "s/with Digital_IO_Sim; use Digital_IO_Sim;/with Digital_IO; use Digital_IO;/g" robot_monitor.adb > tmp1234.adb
	mv tmp1234.adb robot_monitor.adb

	sed "s/with Digital_IO_Sim; use Digital_IO_Sim;/with Digital_IO; use Digital_IO;/g" robot_interface.adb > tmp1234.adb
	mv tmp1234.adb robot_interface.adb

	cp robot_monitor_real.adb robot_monitor.adb
	cp robot_interface_real.adb robot_interface.adb
	gnatmake hanoi.adb

all: real

clean:
	rm -Rf *.o *.ali hanoi *~
