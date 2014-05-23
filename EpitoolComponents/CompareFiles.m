function CompareFiles(f1,f2)

C1 = load(f1);
C2 = load(f2);

if ~isequal(C1,C2)
    errordlg('Files generated are not the same!','File comparison error');
else
    fprintf('file comparison passed\n');
end

end

