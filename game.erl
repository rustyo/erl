-module(game).
-compile(export_all).




init(Moves) -> 
	Board = [
		[0,1,1,0,0,1,0,1,0],
		[0,1,1,1,0,0,0,1,1],
		[1,0,0,0,1,0,0,0,0],
		[0,0,0,0,0,0,0,0,0],
		[1,0,0,1,0,0,0,0,0]
		],
	print(Board),
	play(Board,Moves).

init(Board,Moves) ->
	print(Board),
	play(Board,Moves)
	.

play(_,0) -> io:format("~nend");
play(Board,N) -> 
	Pids = getPids(Board,Board,1),	
	NewBoard = gather(Pids),
	print(NewBoard),
	play(NewBoard,N-1).
	
print([]) -> io:format("~n");
print([H|T]) -> 
	io:format("~p~n", [H]),
	print(T).

gather([]) -> [];
gather([H|T]) -> 
	[gatherRow(H)] ++ gather(T).

gatherRow([]) -> [];
gatherRow([H|T]) -> 
	receive 
		{H,V} -> [V|gatherRow(T)]
	end.

getPids([],_,_) -> [];
getPids([H|T],Board,Row) ->
	[getRowPids(H,Board,Row,1)]
	++ getPids(T,Board,Row+1).

getRowPids([],_,_,_) -> [];
getRowPids([_|T],Board,Row,Column) -> 
	[spawn(game,check,[Board,self(),Row,Column])] 
	++ getRowPids(T,Board,Row,Column+1).


check(Board,PPID,Row,Column) -> 
	L = lists:nth(Row,Board),
	V = lists:nth(Column,L),
	[LC|_] = Board,
	R=lists:nth(Row,Board),
	Height = length(Board),
	Width = length(LC), 
	if 
		Row > 1, Column > 1, Row < Height, Column < Width -> 
			RUp=lists:nth(Row-1,Board),
			RDown=lists:nth(Row+1,Board),
			Neighbour = [getListValue(Column-1,RUp)] ++
				[getListValue(Column, RUp)] ++
				[getListValue(Column+1, RUp)] ++
				[getListValue(Column-1, R)] ++
				[getListValue(Column+1, R)] ++
				[getListValue(Column-1, RDown)] ++ 
				[getListValue(Column, RDown)] ++
				[getListValue(Column+1, RDown)],
			Value = countAlive(Neighbour,V),
			PPID ! {self(),Value};
		Row == 1, Column == 1 -> 
			RDown=lists:nth(Row+1,Board),
			Neighbour = 
				[getListValue(Column+1, R)] ++
				[getListValue(Column, RDown)] ++
				[getListValue(Column+1, RDown)],
			Value = countAlive(Neighbour,V),
			PPID ! {self(),Value};
		Row == 1, Column == Width -> 
			RDown=lists:nth(Row+1,Board),
			Neighbour = 
				[getListValue(Column-1, R)] ++
				[getListValue(Column, RDown)] ++
				[getListValue(Column-1, RDown)],
			Value = countAlive(Neighbour,V),
			PPID ! {self(),Value};
		Row == Height, Column==1 ->	
			RUp=lists:nth(Row-1,Board),
			Neighbour = 
				[getListValue(Column+1, R)] ++
				[getListValue(Column, RUp)] ++
				[getListValue(Column+1, RUp)],
			Value = countAlive(Neighbour,V),
			PPID ! {self(),Value};
		Row == Height, Column== Width ->
			RUp=lists:nth(Row-1,Board),
			Neighbour = 
				[getListValue(Column-1, R)] ++
				[getListValue(Column, RUp)] ++
				[getListValue(Column-1, RUp)],
			Value = countAlive(Neighbour,V),
			PPID ! {self(),Value};
		Row == 1,Column >1, Column < Width ->
			RDown=lists:nth(Row+1,Board),
			Neighbour =
				[getListValue(Column-1, R)] ++
				[getListValue(Column+1, R)] ++
				[getListValue(Column-1, RDown)] ++ 
				[getListValue(Column, RDown)] ++
				[getListValue(Column+1, RDown)],
			Value = countAlive(Neighbour,V),
			PPID ! {self(),Value};
		Row == Height,Column >1, Column < Width ->
			RUp=lists:nth(Row-1,Board),
			Neighbour =
				[getListValue(Column-1, R)] ++
				[getListValue(Column+1, R)] ++
				[getListValue(Column-1, RUp)] ++ 
				[getListValue(Column, RUp)] ++
				[getListValue(Column+1, RUp)],
			Value = countAlive(Neighbour,V),
			PPID ! {self(),Value};
		Row > 1, Row < Height, Column == 1 ->
			RUp=lists:nth(Row-1,Board),
			RDown=lists:nth(Row+1,Board),
			Neighbour =
				[getListValue(Column+1, R)] ++
				[getListValue(Column+1, RUp)] ++ 
				[getListValue(Column, RUp)] ++
				[getListValue(Column+1, RDown)] ++
				[getListValue(Column, RDown)],
			Value = countAlive(Neighbour,V),
			PPID ! {self(),Value};
		Row > 1, Row < Height, Column == Width ->
			RUp=lists:nth(Row-1,Board),
			RDown=lists:nth(Row+1,Board),
			Neighbour =
				[getListValue(Column-1, R)] ++
				[getListValue(Column-1, RUp)] ++ 
				[getListValue(Column, RUp)] ++
				[getListValue(Column-1, RDown)] ++
				[getListValue(Column, RDown)],
			Value = countAlive(Neighbour,V),
			PPID ! {self(),Value};
		true -> io:format("~n")		
	end.


countAlive(L,V) -> 
	Ones = lists:filter(fun(X) -> X == 1 end,L),
	CountOnes = length(Ones),
	if CountOnes == 3 ->
	 	 1;
   	   CountOnes == 2 ->
	  	 V;
	   CountOnes >3; CountOnes<2 ->
	   	 0
	end.

getListValue(N,L) -> lists:nth(N,L).






