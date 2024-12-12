increasing([],_).
increasing([First|Rest], Prev) :-
    Prev =< First,
    increasing(Rest, First).
increasing(List) :-
    increasing(List, 0).

decreasing([], _).
decreasing([First|Rest], Prev) :-
    First =< Prev,
    decreasing(Rest, First).
decreasing(List) :-
    decreasing(List, 1000).

max_difference([], 0).
max_difference([_|[]], 0).
max_difference([First|[Second|Rest]], MaxDifference) :-
    max_difference([Second|Rest], NextMaxDifference),
    CurrentMaxDifference is abs(First-Second),
    max_list([CurrentMaxDifference, NextMaxDifference], MaxDifference).

min_difference([], 1000).
min_difference([_|[]], 1000).
min_difference([First|[Second|Rest]], MinDifference) :-
    min_difference([Second|Rest], NextMinDifference),
    CurrentMinDifference is abs(First-Second),
    min_list([CurrentMinDifference, NextMinDifference], MinDifference).


safe(Report) :-
    (increasing(Report); decreasing(Report)),
    max_difference(Report, MaxDifference),
    MaxDifference =< 3,
    min_difference(Report, MinDifference),
    1 =< MinDifference.

safe_with_dampener(Report) :-
    safe(Report);
    (
        append(Intermediate, Right, Report),
        append(Left, [_], Intermediate),
        append(Left, Right, Without),
        safe(Without)
    ).
        
count_safe([], 0).
count_safe([Report|Remainder], SafeCount) :-
    count_safe(Remainder, PrevSafeCount),
    ((
        safe(Report),
        SafeCount is PrevSafeCount + 1
    );(
        not(safe(Report)),
        SafeCount = PrevSafeCount
    )).

count_safe_with_dampener([], 0).
count_safe_with_dampener([Report|Remainder], SafeCount) :-
    count_safe_with_dampener(Remainder, PrevSafeCount),
    ((
        safe_with_dampener(Report),
        SafeCount is PrevSafeCount + 1
    );(
        not(safe_with_dampener(Report)),
        SafeCount = PrevSafeCount
    )).

run :-
    read_reports(Reports),
    count_safe(Reports, SafeCount),
    count_safe_with_dampener(Reports, SafeCountWithDampener),
    write("Part 1: "),
    write(SafeCount),
    write("\nPart 2: "),
    write(SafeCountWithDampener).

read_reports(Reports) :-
    open('input', read, File),
    read_reports(File, [], Reports),
    close(File).

parse_report(Line, Report) :-
    atom_codes(A, Line),
    atomic_list_concat(As, ' ', A),
    maplist(atom_number, As, Report).

read_reports(File, InitialReports, NewReports) :-
    read_line_to_codes(File, Line),
    ((
        Line \= end_of_file,
        parse_report(Line, NewReport),
        append(InitialReports, [NewReport], Reports),
        read_reports(File, Reports, NewReports)
    ); (
        Line = end_of_file,
        InitialReports = NewReports
    )).

