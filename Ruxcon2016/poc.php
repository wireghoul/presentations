<?php
 /*************************************************
 *                                                *
 * Teaching secure development in under 10minutes *
 *         Ruxcon 2016 turbo talk PoC             *
 *   By @Wireghoul - www.justanotherhacker.com    *
 *                                                *
 *************************************************/

@include_once('database.php');
@include_once('core.php');

    //Search by id or title
    $usAction = $_GET['action'];
    $uiId     = $_GET['id'];
    $usTitle  = $_GET['title'];

    //Sanitise
    $ssAction = ($usAction === "Searchid" ? "Searchid" : "Searchtitle");
    $siId     = intval($uiId);
    $ssTitle  = ereg_replace('(.*)', '\\1', $usTitle);
    $ssFilter = $_GET['filter'];

    switch($ssAction) {
        case "Searchid":
            echo "Searching for data matching id: $usId\n";
            $rwData = @mysql_query("SELECT * FROM data where id = $siId and account_id = " . $_SESSION['account_id']);

        case "Searchtitle":
            echo "Searching for data matching title: $ssTitle\n";
            $rwData = @mysql_query("SELECT * FROM data where title like '%$ssTitle%'");
    }
?> 
