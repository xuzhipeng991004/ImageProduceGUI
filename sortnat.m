function [CoS,ind,ChA,NuA] = sortnat(CoS,varargin)
%sortnat函数用来将文件夹或文件夹的文件进行排序，按照的是window中排序方式，是下载的函数
% Customizable natural-order sort of a cell array of strings.
%
% (c) 2012 Stephen Cobeldick
%
% ### Function ###
%
% Sort the strings in a cell array of strings by character order (ASCII)
% and the value of any numeric tokens.
%
% By default sorts case-insensitive ascending, with integer numeric tokens.
% Optional inputs may be used control the format of the numeric tokens
% within the strings (see 'Tokens'), case sensitivity and sort direction.
%
% Syntax:
%  SortedCellStr = sortnat(CellStr)
%  [SortedCellStr,SortIndex] = sortnat(CellStr,...);
%  [...] = sortnat(CellStr,RegExp)
%  [...] = sortnat(CellStr,RegExp,Case)
%  [...] = sortnat(CellStr,RegExp,Case,Descend)
%  [...] = sortnat(CellStr,RegExp,Case,Descend,Format)
%
% See also SORT SORTROWS UNIQUE CELLSTR REGEXP SSCANF
%
% ### RegExp Tokens ###
%
% # A numeric token consists of some combination of digits, may optionally
%   include a +/- sign, decimal point, exponent, etc. The numeric tokens
%   must be able to be parsed by "sscanf" (*default format '%f'), and may
%   be defined by the optional "regexp" regular expression input, eg:
%
%   Regular Expression Example: | Matches Numeric Token:
%   ----------------------------|---------------------------------
%                         '\d+' | integer (*default).
%   ----------------------------|---------------------------------
%                   '(-|+)?\d+' | integer with optional +/- sign.
%   ----------------------------|---------------------------------
%                 '\d+(\.\d+)?' | integer or decimal.
%   ----------------------------|---------------------------------
%                       \d+|inf | integer or infinite value.
%   ----------------------------|---------------------------------
%               '(-|+)\d+\.\d+' | decimal with +/- sign.
%   ----------------------------|---------------------------------
%                     '\d+e\d+' | exponential.
%   ----------------------------|---------------------------------
%     '[1-9]\d*|(?<=0?)0(?!\d)' | integer excluding leading zeros.
%
% # A character is any other single character: all other characters not
%   matching the "regexp" pattern, including space & non-printing characters.
%
% ### Examples (comparison with "sort") ###
%
% # Integer numeric tokens:
%
% A = {'File2.txt','File10.txt','File1.txt'};
% sort(A)
%  ans = {'File1.txt','File10.txt','File2.txt'}
% sortnat(A)
%  ans = {'File1.txt','File2.txt','File10.txt'}
%
% # Integer or decimal numeric tokens, possibly with +/- signs:
%
% B = {'File102.txt','File11.5.txt','File-1.4.txt','File+0.3.txt'};
% sort(B)
%  ans = {'File+0.3.txt','File-1.4.txt','File102.txt','File11.5.txt'}
% sortnat(B,'(-|+)?\d+(\.\d+)?')
%  ans = {'File-1.4.txt','File+0.3.txt','File11.5.txt','File102.txt'}
%
% # Integer or decimal numeric tokens, possibly with an exponent:
%
% C = {'A_0.56e+07','A_4.3E2','A_10000','A_9.8'}
% sort(C)
%  ans = {A_'0.56e+07','A_10000','A_4.3E2','A_9.8'}
% sortnat(C,'\d+(\.\d+)?(e(+|-)?\d+)?')
%  ans = {'A_9.8','A_4.3E2','A_10000','A_0.56e+07'}
%
% # ASCII order (including non-printing characters):
% sortnat(CellStr,'[]',true);
%
% ### Inputs and Outputs ###
%
% Outputs:
%   Out = CellOfStrings, InC sorted into natural-order, same size as InC.
%   ind = Numeric array, such that OutCoS = InCoS(ind), same size as InC.
% For debugging: each row is one string, linear-indexed from InC:
%   ChA = Character array, all separate non-numeric characters.
%   NuA = Numeric array, "sscanf" converted numeric values.
%
% Inputs:
%   InC = CellOfStrings, whose string elements are to be sorted.
%   tok = String, "regexp" numeric token extraction expression, '\d+'*.
%   cse = Logical scalar, true/false* -> case sensitive/insensitive.
%   dsc = Logical scalar, true/false* -> descending/ascending sort.
%   fmt = String, "sscanf" numeric token conversion format, '%f'*.
%
% An empty input [] uses the default input option value (indicated *).
%
% Outputs = [Out,ind,chr,num]
% Inputs = (InC,tok*,cse*,dsc*,fmt*)

DfAr = {'\d+',false,false,'%f'}; % *{tok,cse,dsc,fmt}
DfIx = ~cellfun('isempty',varargin);
DfAr(DfIx) = varargin(DfIx);
[tok,cse,dsc,fmt] = DfAr{1:4};
%
CsC = {'ignorecase','matchcase'};
SrS = ['(',tok,')|.'];
%
% Split strings into tokens:
[MtE,ToX] = regexp(CoS(:),SrS,'match','tokenextents',CsC{1+cse});
%
Clx = cellfun('length',MtE);
Cly = numel(MtE);
Clz = max(Clx);
%
% Initialize arrays:
ChA = char(zeros(Cly,Clz));
ChI = false(Cly,Clz);
MtC = cell(Cly,Clz);
NuA = NaN(Cly,Clz);
NuI = false(Cly,Clz);
%
% Merge tokens into cell array:
ind = 1:Cly;
for n = ind(Clx>0)
    cj = cellfun('isempty',ToX{n});
    ChI(n,1:Clx(n)) = cj;
    NuI(n,1:Clx(n)) = ~cj;
    MtC(n,1:Clx(n)) = MtE{n};
end
% Transfer tokens to numeric and char arrays:
ChA(ChI) = [MtC{ChI}];
NuA(NuI) = sscanf(sprintf('%s ',MtC{NuI}),fmt);
%
if cse
    MtC = ChA;
else
    MtC = lower(ChA);
end
%
MoC = {'ascend','descend'};
MoS = MoC{1+dsc};
%
% Sort each column of characters and numeric values:
ei = (1:Cly)';
for n = Clz:-1:1
    % Sort char and numeric arrays:
    [~,ci] = sort(MtC(ind,n),MoS);
    [~,ni] = sort(NuA(ind,n),MoS);
    % Relevant indices only:
    cj = ChI(ind(ci),n);
    nj = NuI(ind(ni),n);
    ej = ~ChI(ind,n) & ~NuI(ind,n);
    % Combine indices:
    if dsc
        ind = ind([ci(cj);ni(nj);ei(ej)]);
    else
        ind = ind([ei(ej);ni(nj);ci(cj)]);
    end
end
%
ind = reshape(ind,size(CoS));
CoS = reshape(CoS(ind),size(CoS));
%----------------------------------------------------------------------End!
