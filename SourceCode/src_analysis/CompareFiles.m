function CompareFiles(f1,f2)

C1 = load(f1);
C2 = load(f2);

if ~isequal(C1,C2)
    errordlg('Files generated are not the same!','File comparison error');
    fprintf('file comparison FAILED HERE: %s vs %s\n', f1,f2);
else
    fprintf('file comparison passed\n');
end

end

