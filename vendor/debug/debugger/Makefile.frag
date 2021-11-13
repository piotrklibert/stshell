Debugger_FILES = \

$(Debugger_FILES):
$(srcdir)/packages/debug/debugger/stamp-classes: $(Debugger_FILES)
	touch $(srcdir)/packages/debug/debugger/stamp-classes
