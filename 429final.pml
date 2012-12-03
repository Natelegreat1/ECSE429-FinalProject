mtype = {Seq, Ack, Establishing, Established}
chan SYN = [1] of {mtype, int};
chan SEVER_STATE = [1] of {mtype, int}

int Timer_A = 0;
int x = 0;
int y = 0;

proctype HostA()
{
	int state = -1;
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
	SYN?Seq, x;
	SYN!Seq, y;
	SYN!Ack, x++;
	SYN?Seq, x;
	SYN?Ack, y;
	
	SEVER_STATE!Established;
	
	
}

proctype Server()
{



}


init
{
	run HostA();
	run HostB();

}