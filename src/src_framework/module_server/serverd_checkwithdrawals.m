function [ interrupt ] = serverd_checkwithdrawals( CLIPROINST, pools, OPTIONS )
%SERVERD_CHECKWITHDRAWALS Summary of this function goes here
%   Detailed explanation goes here
interrupt = false;
%% Check for withdrawals
if ~(~isempty(OPTIONS) && strcmp(OPTIONS,'bypass-withdrawals')>0)
    if(~isempty(CLIPROINST.withdrawals.tags))
        if isa(CLIPROINST.withdrawals.tags.tag,'char')
            CLIPROINST.withdrawals.tags.tag = {CLIPROINST.withdrawals.tags.tag};
        end
        for i = 1:numel(CLIPROINST.withdrawals.tags.tag)
            if pools.existsTag(CLIPROINST.withdrawals.tags.tag(i));
                message = sprintf('-----------------------------------------------------------------------');
                log2dev(message,'INFO');
                log2dev(sprintf('The process named %s will not be submitted since it has been already computed in the current pool',...
                    CLIPROINST.uid),'INFO');
                message = sprintf('-----------------------------------------------------------------------');
                log2dev(message,'INFO');
                interrupt = true;
            end
        end
    end
end
end

