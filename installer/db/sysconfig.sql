SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;


INSERT INTO `sysconfig` (`cfg_name`, `cfg_value`) VALUES
('db_version', '"install"'),
('default_config_chain', '["27","28","6","22"]'),
('general_member_delete_timeout', '"30"'),
('general_vps_delete_timeout', '"30"'),
('maintenance_mode', 'false'),
('playground_backup', 'false'),
('playground_default_config_chain', '["27","28","6","17"]'),
('playground_enabled', 'false'),
('playground_vps_lifetime', '30');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
