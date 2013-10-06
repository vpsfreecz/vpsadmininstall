SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;


INSERT INTO `config` (`id`, `name`, `label`, `config`) VALUES
(1, 'base-privvmpages', 'Base privvmpages OpenVZ configuration', 'NUMPROC="2572:2572"\r\nAVNUMPROC="1286:1286"\r\nNUMTCPSOCK="2572:2572"\r\nNUMOTHERSOCK="2572:2572"\r\nVMGUARPAGES="233030:9223372036854775807"\r\n\r\n# Secondary parameters\r\nKMEMSIZE="105377561:115915317"\r\nTCPSNDBUF="24590942:35125854"\r\nTCPRCVBUF="24590942:35125854"\r\nOTHERSOCKBUF="12295471:22830383"\r\nDGRAMRCVBUF="12295471:12295471"\r\nOOMGUARPAGES="9223372036854775807:9223372036854775807"\r\nPRIVVMPAGES="1048576:1585152"\r\nSWAPPAGES="0:0"\r\n\r\n# Auxiliary parameters\r\nLOCKEDPAGES="5145:5145"\r\nSHMPAGES="139818:139818"\r\nPHYSPAGES="0:9223372036854775807"\r\nNUMFILE="41152:41152"\r\nNUMFLOCK="1000:1100"\r\nNUMPTY="257:257"\r\nNUMSIGINFO="1024:1024"\r\nDCACHESIZE="23013157:23703552"\r\nNUMIPTENT="10000:10000"\r\nCPUUNITS="32320"\r\n\r\n# Standard IOPRIO\r\n\r\nIOPRIO="4"\r\n\r\nQUOTAUGIDLIMIT="1000"'),
(2, 'privvmpages-4g-6g', 'RAM privvmpages 4G (6G)', 'PRIVVMPAGES="1048576:1572864"\r\n'),
(3, 'privvmpages-6g-6g', 'RAM privvmpages 6G (6G)', 'PRIVVMPAGES="1572864"\r\n'),
(4, 'privvmpages-8g-8g', 'RAM privvmpages 8G (8G)', 'PRIVVMPAGES="2097152"\r\n'),
(5, 'hdd-20g', 'HDD 20 GB', 'DISKSPACE="20G:20G"\r\n'),
(6, 'hdd-60g', 'HDD 60 GB', 'DISKSPACE="60G:60G"\r\n'),
(8, 'hdd-80g', 'HDD 80 GB', 'DISKSPACE="80G:80G"\r\n'),
(9, 'hdd-160g', 'HDD 160 GB', 'DISKSPACE="160G:160G"\r\n'),
(10, 'hdd-300g', 'HDD 300 GB', 'DISKSPACE="300G:300G"\r\n'),
(11, 'cpu-1c-50', 'CPU 1 core 50%', 'CPUS="1",\r\nCPULIMIT="50"'),
(12, 'cpu-1c-75', 'CPU 1 core 75%', 'CPUS="1",\r\nCPULIMIT="75"'),
(13, 'cpu-1c-100', 'CPU 1 core 100%', 'CPUS="1",\r\nCPULIMIT="100"'),
(14, 'cpu-2c-150', 'CPU 2 core 150%', 'CPUS="2",\r\nCPULIMIT="150"'),
(15, 'cpu-2c-200', 'CPU 2 core 200%', 'CPUS="2",\r\nCPULIMIT="200"'),
(16, 'cpu-3c-250', 'CPU 3 core 250%', 'CPUS="3",\r\nCPULIMIT="250"'),
(17, 'cpu-3c-300', 'CPU 3 core 300%', 'CPUS="3",\r\nCPULIMIT="300"'),
(18, 'cpu-4c-350', 'CPU 4 core 350%', 'CPUS="4",\r\nCPULIMIT="350"'),
(19, 'cpu-5c-500', 'CPU 5 core 500%', 'CPUS="5",\r\nCPULIMIT="500"'),
(20, 'cpu-6c-600', 'CPU 6 core 600%', 'CPUS="6",\r\nCPULIMIT="600"'),
(21, 'cpu-7c-700', 'CPU 7 core 700%', 'CPUS="7",\r\nCPULIMIT="700"'),
(22, 'cpu-8c-800', 'CPU 8 core 800%', 'CPUS="8",\r\nCPULIMIT="800"'),
(23, 'cpu-4c-400', 'CPU 4 core 400%', 'CPUS="4",\r\nCPULIMIT="400"'),
(24, 'hdd-500g', 'HDD 500 GB', 'DISKSPACE="500G:500G"\r\n'),
(25, 'ioprio-low', 'IO priority - lower', 'IOPRIO="1"'),
(26, 'ioprio-higher', 'IO priority - higher', 'IOPRIO="6"'),
(27, 'base-vswap', 'Base VSwap OpenVZ configuration', '# RAM\r\nPHYSPAGES="0:4G"\r\n\r\n# Swap\r\nSWAPPAGES="unlimited"\r\n\r\nNUMPROC="unlimited"\r\nAVNUMPROC="unlimited"\r\nNUMTCPSOCK="unlimited"\r\nNUMOTHERSOCK="unlimited"\r\nVMGUARPAGES="unlimited"\r\n\r\n# Secondary parameters\r\nKMEMSIZE="unlimited"\r\nTCPSNDBUF="unlimited"\r\nTCPRCVBUF="unlimited"\r\nOTHERSOCKBUF="unlimited"\r\nDGRAMRCVBUF="unlimited"\r\nOOMGUARPAGES="unlimited"\r\nPRIVVMPAGES="unlimited"\r\nSWAPPAGES="0:0"\r\n\r\n# Auxiliary parameters\r\nLOCKEDPAGES="unlimited"\r\nSHMPAGES="unlimited"\r\nPHYSPAGES="unlimited"\r\nNUMFILE="unlimited"\r\nNUMFLOCK="unlimited"\r\nNUMPTY="unlimited"\r\nNUMSIGINFO="unlimited"\r\nDCACHESIZE="unlimited"\r\nNUMIPTENT="unlimited"\r\nCPUUNITS="32320"\r\n\r\n# Standard IOPRIO\r\n\r\nIOPRIO="4"\r\n\r\n#QUOTAUGIDLIMIT="1000"'),
(28, 'ram-vswap-4g-swap-0g', 'RAM 4 GB, 0 GB swap', '# RAM\r\nPHYSPAGES="0:4G"\r\n\r\n# Swap\r\nSWAPPAGES="0"'),
(29, 'ram-vswap-8g-swap-0g', 'RAM 8 GB, 0 GB swap', '# RAM\r\nPHYSPAGES="0:8G"\r\n\r\n# Swap\r\nSWAPPAGES="0"'),
(30, 'hdd-120g', 'HDD 120 GB', 'DISKSPACE="120G:120G"\r\n'),
(31, 'ram-vswap-32g-swap-0g', 'RAM 32 GB, 0 GB swap', '# RAM\r\nPHYSPAGES="0:32G"\r\n\r\n# Swap\r\nSWAPPAGES="0"'),
(32, 'cpu-unlimited', 'CPU Unlimited', 'CPUS="0"\r\nCPULIMIT="0"'),
(33, 'ram-vswap-16g-swap-0g', 'RAM 16 GB, 0 GB swap', '# RAM\r\nPHYSPAGES="0:16G"\r\n\r\n# Swap\r\nSWAPPAGES="0"'),
(34, 'swap-2g', 'Swap 2 GB', 'SWAPPAGES="2G"\r\n');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;