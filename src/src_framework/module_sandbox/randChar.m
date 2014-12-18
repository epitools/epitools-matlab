function [ strings ] = randChar(len, num, alphabet)
% string = randChar(len, num, alphabet):
% generate random string(s) of defined size out of a given alphabet
%
% input:   - len : string length
%          - num (optional) : number of strings
%          - alphabet (optional) : vector of symbols, default: a,b,..,z
% output:  - strings : matrice of random strings
%
% example: to generate three random strings of length 12 consisting of
%          chars G,E,F,...Y,Z and a,b,c,d,e:
%          somestrings = randChar(3, 12,['G':'Z','a':'e'])
%          string1 = somestrings(1,:)
%          string2 = somestrings(2,:) ...
% 2011, desperate-engineers.com
   if nargin == 1
      num = 1;    % default  one string output
   end
   if nargin < 3
      alphabet = 'a':'z'; % lowercase letters - 'a'..'z'
   end
 
   numbers = randi(numel(alphabet), [num, len] );
   strings = char(alphabet(numbers));
end