<?php
/*
  Constants used by GPU server
*/

// cluster settings
// maximum number of online nodes shown in list_clients.php
$max_online_clients_xml = 2000;

// maximum number of online nodes shown in list_servers.php
$max_online_servers_xml = 2000;

// this is the update interval in seconds of clients
// which touch the report_client.php script
// to report their online presence.
$client_update_interval = 60;

// this is the update interval in seconds of servers
$server_update_interval = 3600;
?>