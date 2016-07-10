function fig_rotate(varargin)
a = 1;
b = 10;
% d=1;    % rotation delta angle
if isempty(varargin)
    d = 10;
else
    d = varargin{1};
%     text = varargin{2};
end

% text = varargin{:};

while a<=360
    a = a + d;
    view(a,b)
    drawnow
%     name = 'Test Rotate';
%     title(name);
%     saveas(gca,sprintf('%s rotation=%d.png',text,a));
%     clc
%     fprintf('Saving: %3.0f%%\n',a/360*100)
end