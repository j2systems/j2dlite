#!/bin/bash
add_registry(){

	#$1=username $2=management host $3=container name
	ssh $1@$2 "/bin/reg_add.cmd $3 $(hostname)" >/dev/null
}

remove_registry(){
	#$1=username $2=management host $3=container name
	ssh $1@$2 "/bin/reg_delete.cmd $3" >/dev/null
}
