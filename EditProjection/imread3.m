function A=imread3(filename)

[a,b]=size(imfinfo(filename));


for n=1:a,
   A(:,:,n)=(imread(filename,n)); 
end

