var xhr = new XMLHttpRequest();
xhr.open("POST", ajaxUrl, false);
xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
xhr.send("matched=yes");
