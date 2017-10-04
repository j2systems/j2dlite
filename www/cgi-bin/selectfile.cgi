#!/bin/bash
. bin/image_array.sh
cat base/header
echo "<label>Select file: <input type=\"file\" name=\"imagefile\" accept=\"image/jpeg, image/png\"></label>
<input type=\"submit\" value=\"upload\">"
cat base/footer
