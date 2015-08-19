// 14 august 2015
#import "uipriv_darwin.h"

// TODO
// - even with the uiDarwinControlRelayoutParent() calls, we still need to click the button twice for the ambiguity to go away

struct uiGroup {
	uiDarwinControl c;
	NSBox *box;
	uiControl *child;
	int margined;
};

static void onDestroy(uiGroup *);

uiDarwinDefineControlWithOnDestroy(
	uiGroup,								// type name
	uiGroupType,							// type function
	box,									// handle
	onDestroy(this);						// on destroy
)

static void onDestroy(uiGroup *g)
{
	if (g->child != NULL) {
		uiControlSetParent(g->child, NULL);
		uiControlDestroy(g->child);
	}
}

// TODO group container update

static void groupRelayout(uiDarwinControl *c)
{
	uiGroup *g = uiGroup(c);
	uiDarwinControl *cc;
	NSView *childView;

	if (g->child == NULL)
		return;
	cc = uiDarwinControl(g->child);
	childView = (NSView *) uiControlHandle(g->child);
	// first relayout the child
	(*(cc->Relayout))(cc);
	// now relayout ourselves
	layoutSingleView(g->box, childView, g->margined);
}

char *uiGroupTitle(uiGroup *g)
{
	return PUT_CODE_HERE;
}

void uiGroupSetTitle(uiGroup *g, const char *title)
{
	[g->box setTitle:toNSString(title)];
	// changing the text might necessitate a change in the groupbox's size
	uiDarwinControlTriggerRelayout(uiDarwinControl(g));
}

void uiGroupSetChild(uiGroup *g, uiControl *child)
{
	NSView *childView;

	if (g->child != NULL) {
		childView = (NSView *) uiControlHandle(g->child);
		[childView removeFromSuperview];
		uiControlSetParent(g->child, NULL);
	}
	g->child = child;
	if (g->child != NULL) {
		childView = (NSView *) uiControlHandle(g->child);
		uiControlSetParent(g->child, uiControl(g));
		[g->box addSubview:childView];
		uiDarwinControlTriggerRelayout(uiDarwinControl(g));
	}
}

int uiGroupMargined(uiGroup *g)
{
	return g->margined;
}

void uiGroupSetMargined(uiGroup *g, int margined)
{
	g->margined = margined;
	if (g->child != NULL)
		uiDarwinControlTriggerRelayout(uiDarwinControl(g));
}

uiGroup *uiNewGroup(const char *title)
{
	uiGroup *g;

	g = (uiGroup *) uiNewControl(uiGroupType());

	g->box = [[NSBox alloc] initWithFrame:NSZeroRect];
	[g->box setTitle:toNSString(title)];
	[g->box setBoxType:NSBoxPrimary];
	[g->box setBorderType:NSLineBorder];
	[g->box setTransparent:NO];
	[g->box setTitlePosition:NSAtTop];
	// we can't use uiDarwinSetControlFont() because the selector is different
	[g->box setTitleFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];

	uiDarwinFinishNewControl(g, uiGroup);
	uiDarwinControl(g)->Relayout = groupRelayout;

	return g;
}
