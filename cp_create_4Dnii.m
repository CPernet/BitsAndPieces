function fn_out = cp_create_4Dnii(fn_in,params)

% Small function to create an arbitray 4D nifti file.
%
% INPUT
% fn_in     : filename for the generated file. Using the current folder if
%             no path information is provided. Default '4D.nii'
% params    : structure with parameters of the image to generate
%   .sz     : image size, def. [32x32x32x4]
%   .type   : value type, def. 2 -> uint8
%
% OUTPUT
% fn_out    : full filename (incl. path) of created file
%__________________________________________________________________________
% Copyright (C) 2017 Cyclotron Research Centre

% Written by C. Phillips.
% Cyclotron Research Centre, University of Liege, Belgium

% Checking input and initializing defaults
params_def = struct( ...
    'sz', [32 32 32 4], ...
    'type', 2);
if nargin<2, params = params_def; end
if nargin<1, fn_in = '4D.nii'; end

params = crc_check_struct(params_def,params);

% Extracting filename bits and fixing things
[pth,nam,ext] = spm_fileparts(fn_in);
if isempty(pth), pth = pwd; end
if isempty(ext) || ~strcmp(ext,'.nii')
    ext = '.nii';
    fprintf('\nSetting extension to ''.nii''!');
end

% Create the desired volume, using SPM's functions.
% Check spm_vol and spm_create_vol
Vo = struct( ...
    'fname', fullfile(pth,[nam,ext]), ...
    'dim', params.sz(1:3), ...
    'n', [1 1], ...
    'dt', [params.type 0], ...
    'mat', eye(4), ...
    'pinfo', [1 0 352]', ...
    'descrip', 'dummy 4D nifti file');
nBytes = spm_type(params.type,'bits')/8 * prod(Vo.dim);
vVol = zeros(Vo.dim);

for ii=1:params.sz(4)
    V_ii = Vo;
    V_ii.pinfo(3) = V_ii.pinfo(3) + (ii-1)*nBytes;
    V_ii.n(1) = ii;
    V_ii = spm_create_vol(V_ii);
    V_ii = spm_write_vol(V_ii,vVol);
end

fn_out = V_ii.fname;

end

function p = crc_check_struct(p_def,p)
% Function to automatically check and fix the content of a structure 'p', 
% using a default flag structure 'p_def', adding the missing fields and 
% putting in the default value if none was provided.

f_names = fieldnames(p_def);
% list fields in default structure

Nfields = length(f_names);
for ii=1:Nfields
    % Update the output if
    % - a field is missing
    % - the field is empty when it shouldn't
    if ~isfield(p,f_names{ii}) || ...
            ( isempty(p.(f_names{ii})) && ~isempty(p_def.(f_names{ii})) )
        p.(f_names{ii}) = p_def.(f_names{ii});
    end
end

end

