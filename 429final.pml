/*States*/
#define CLOSED 0
#define LISTEN 1
#define SYN_RCVD 2
#define SYN_SENT 3
#define ESTABLISHED_CONNECTION 4
#define FIN_WAIT_1 5
#define FIN_WAIT_2 6
#define TIMED_WAIT 7
#define CLOSING 8
#define CLOSE_WAIT 9
#define LAST_ACK 10

/*Roles*/
#define CLIENT 0
#define SERVER 1

/*Message Types*/
mtype = {Seq, Ack, Establishing, Established}

/*Channels*/
chan hostA_internet = [1] of {mtype, int};
chan hostB_internet = [1] of {mtype, int};

/*States of Processes*/
byte hostA_state = CLOSED;
byte hostB_state = CLOSED;

/*Role of Processes*/
byte hostA_role;
byte hostB_role;

/*Storage for received messages*/
int hostA_msg;
int hostB_msg;
int internet_msg;


int Timer_A = 0;
int x = 0;
int y = 0;

proctype HostA()
{
	byte hostA_state = CLOSED;
	hostA_msg =0;
	hostA_role = CLIENT;
	do
	::
		if
		::(hostA_state == CLOSED)->
			if
			:: (hostA_role == CLIENT) ->
				
			:: (hostA_role == SERVER) ->
			
			fi;
		::(hostA_state == LISTEN)->
			if
			:: (hostA_role == CLIENT) ->
				
			:: (hostA_role == SERVER) ->
			
			fi;
		::(hostA_state == SYN_RCVD)->
			if
			:: (hostA_role == CLIENT) ->
				
			:: (hostA_role == SERVER) ->
			
			fi;
		::(hostA_state == SYN_SENT)->
			if
			:: (hostA_role == CLIENT) ->
				
			:: (hostA_role == SERVER) ->
			
			fi;
		::(hostA_state == ESTABLISHED_CONNECTION)->
			if
			:: (hostA_role == CLIENT) ->
				
			:: (hostA_role == SERVER) ->
			
			fi;
		::(hostA_state == FIN_WAIT_1)->
			if
			:: (hostA_role == CLIENT) ->
				
			:: (hostA_role == SERVER) ->
			
			fi;
		::(hostA_state == FIN_WAIT_2)->
			if
			:: (hostA_role == CLIENT) ->
				
			:: (hostA_role == SERVER) ->
			
			fi;
		::(hostA_state == TIMED_WAIT)->
			if
			:: (hostA_role == CLIENT) ->
				
			:: (hostA_role == SERVER) ->
			
			fi;
		::(hostA_state == CLOSING)->
			if
			:: (hostA_role == CLIENT) ->
				
			:: (hostA_role == SERVER) ->
			
			fi;
		::(hostA_state == CLOSE_WAIT)->
			if
			:: (hostA_role == CLIENT) ->
				
			:: (hostA_role == SERVER) ->
			
			fi;
		::(hostA_state == LAST_ACK)->
			if
			:: (hostA_role == CLIENT) ->
				
			:: (hostA_role == SERVER) ->
			
			fi;
		fi;
	od;

	
	
	SEVER_STATE!Establishing;
	
	x++;
	SYN!Seq, x;
	SYN?Seq, y;
	SYN?Ack, x;
	SYN!Seq, x++;
	SYN!Ack, y++;
	
	SERVER_STATE?state;
	
	if
	:: (state == Established) ->
	
	fi;
	
}

proctype HostB()
{
	byte hostB_state = CLOSED;
	hostB_msg = 0;
	hostB_role = SERVER;
	
	do
	::
		if
		::(hostB_state == CLOSED)->
			if
			:: (hostB_role == CLIENT) ->
				
			:: (hostB_role == SERVER) ->
			
			fi;
		::(hostB_state == LISTEN)->
			if
			:: (hostB_role == CLIENT) ->
				
			:: (hostB_role == SERVER) ->
			
			fi;
		::(hostB_state == SYN_RCVD)->
			if
			:: (hostB_role == CLIENT) ->
				
			:: (hostB_role == SERVER) ->
			
			fi;
		::(hostB_state == SYN_SENT)->
			if
			:: (hostB_role == CLIENT) ->
				
			:: (hostB_role == SERVER) ->
			
			fi;
		::(hostB_state == ESTABLISHED_CONNECTION)->
			if
			:: (hostB_role == CLIENT) ->
				
			:: (hostB_role == SERVER) ->
			
			fi;
		::(hostB_state == FIN_WAIT_1)->
			if
			:: (hostB_role == CLIENT) ->
				
			:: (hostB_role == SERVER) ->
			
			fi;
		::(hostB_state == FIN_WAIT_2)->
			if
			:: (hostB_role == CLIENT) ->
				
			:: (hostB_role == SERVER) ->
			
			fi;
		::(hostB_state == TIMED_WAIT)->
			if
			:: (hostB_role == CLIENT) ->
				
			:: (hostB_role == SERVER) ->
			
			fi;
		::(hostB_state == CLOSING)->
			if
			:: (hostB_role == CLIENT) ->
				
			:: (hostB_role == SERVER) ->
			
			fi;
		::(hostB_state == CLOSE_WAIT)->
			if
			:: (hostB_role == CLIENT) ->
				
			:: (hostB_role == SERVER) ->
			
			fi;
		::(hostB_state == LAST_ACK)->
			if
			:: (hostB_role == CLIENT) ->
				
			:: (hostB_role == SERVER) ->
			
			fi;
		fi;
	od;
	
	
	
	SYN?Seq, x ;
	SYN!Seq, y;
	SYN!Ack, x++;
	SYN?Seq, x;
	SYN?Ack, y;
	
	SEVER_STATE!Established;
	
	
}

proctype Internet()
{




}


init
{
	run HostA();
	run HostB();
	proctype Internet();

}