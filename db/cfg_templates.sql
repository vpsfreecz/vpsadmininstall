SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;


INSERT INTO `cfg_templates` (`templ_id`, `templ_name`, `templ_label`, `templ_info`, `special`, `templ_enabled`, `templ_supported`, `templ_order`) VALUES
(1, 'scientific-6-x86_64', 'Scientific Linux 6', '', '', 1, 1, 1),
(2, 'debian-7.0-x86_64', 'Debian 7.0', '', '', 1, 1, 1),
(3, 'ubuntu-12.04-x86_64', 'Ubuntu 12.04', '', '', 1, 1, 1),
(4, 'suse-12.3-x86_64', 'OpenSUSE 12.3', '', '', 1, 1, 1);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
