# Director: Follow-Up Questions for Noah

**Date:** February 6, 2026
**Purpose:** Things you might not be thinking about, based on deep competitive analysis

These questions are organized from most strategic to most tactical. You don't need answers for all of them right now - they're designed to surface decisions that will matter as Director evolves.

---

## Strategic Identity Questions

### 1. How opinionated should Director be?
The most successful tools in this space (GSD, Autospec) are highly opinionated - they have ONE way of doing things. The most flexible tools (OpenSpec, Beads) give users choices. Vibe coders benefit enormously from opinionated defaults, but too rigid and they'll feel constrained.

**The tension:** A vibe coder who says "I want to skip planning and just build" - does Director allow this, or insist on the spec-first process?

**What I'd recommend thinking about:** A "guided" mode (full workflow) and a "quick" mode (describe and go), with guided as the default. GSD does this well with its depth settings.
**Answer**: I like the idea of guided mode as a default and then quick mode for people who want to just get going. I know there will be some users who will want to skip planning and just build. Maybe they have the skill set to do that or the vision, but I think it might be worth having.

Having it set up so that the AI, if they forget to mention, no, let's say they say they want to do the quick version, the AI should be able to analyze their request and their initial prompt and say something to the effect of, "Hey, just so you know, this is an intricate thing and it would probably pan out better if you use the guided mode. As long as you know that, if you want to proceed in quick mode, then we'll proceed."

There's something to that effect, because the problem here is that a non-coder might think that the quick way is the best way or the fastest way, and not realize that the guided mode might take longer at the start, but will save time in the long run because the guided mode might prevent bugs, it might prevent conflict of features and things like that that the non-coder didn't even think about.

So I think it should be opinionated, highly opinionated, but allow the flexibility for people who request or demand it with the quick mode. Also, it's worth mentioning here, I believe in the GSD platform, quick mode is meant for tasks rather than, let's say, starting a whole new project. Is that right? I feel like that might be relevant here.

We want a mechanism if somebody is using this new director method and they have a functioning product and they want to implement a small change. It should be doable without having to run the entire workflow. But the AI should be smart enough to recognize that and say, "Hey, there's a lot more to this than what you're thinking. I recommend switching to guided mode or something like that." 

### 2. Is Director a product or a community project?
The brainstorm document positions Director as open source, but your inspiration projects reveal different sustainability models:
- **GSD**: Open source, community-maintained
- **Autospec**: Open source, solo-maintained
- **Claude Task Master**: Open source with npm distribution, community contributors
- **Vibe-Kanban**: Freemium (open source local + paid cloud)

**What this means for you:** If Director is purely community-driven, you need contributors. If it's a product (director.cc suggests this), you need a business model. The answer affects every architectural decision.
**Answer**: I'd like your honest assessment or feedback on this. I'm inclined to think open source and solo maintained only because I don't have experience working in GitHub with collaborators. I don't know how that works. I don't want to have the additional burden or responsibility to be looking at what changes a contributor made and then having to decide if I want to allow that to affect my version.

My goal is to develop this system, ideally for me. I will use this to build all of the upcoming projects that I'm working on because I am an example of the audience that I'm targeting with this. I'm a solo developer, solo entrepreneur. I know that AI has the ability to build incredible things and I need to know enough to build them, but I want to trust my systems. I don't want to have to become a world-class coding expert.

Having said that, it could be that it's a product and if it is, it's going to be free. My goal is not to make money off of this or to monetize it because I realized this space is changing way too fast and I don't want to have something become obsolete and then I'm stuck with a product.

My goal with launching this really is to get my name out there to be seen in the community because I feel like a well-executed product like this or open source product, whatever it is, will help organizations to see and to realize that I have a strong grasp of how to implement AI effectively into real-world applications. For example, making coding available to non-coders thanks to AI.

So if there is a larger end goal, it's for me to prove to large companies that I have a unique vision and the right skills and talent to put systems together that empower ordinary people with AI, because that's the kind of skill that I need to show in order to one day be considered as a candidate for upcoming AI positions like Chief AI Officer or Director of AI or things like that within larger organizations. That's kind of what's driving this strategy and this thinking for me.

Of course, I want this to be a product that stands on its own and truly does empower non-coders. But I want that primarily for me, even if I'm the only customer who uses this, it will make my life easier and that will have been enough.

So with that context, you tell me what is your recommendation. Do we make this open source solo maintained? Do we treat it as a product? I want the repo to be public because I want people to see it and star it. With that context, you tell me which direction you suggest here: open-source, solo maintained, vs community maintained, vs product. 

### 3. What does "launch" look like?
You have a website (director.cc). Is Director launched when:
- (a) The plugin is installable and the basic workflow works?
- (b) It's been tested by 5-10 real users and refined?
- (c) The visual dashboard exists?
- (d) It's better than GSD for your specific audience?

Defining "launch" now prevents scope creep.
**Answer**: For me, the launch looks like the plugin is installable, the basic workflow works, and it can be used. In fact, as soon as it's ready, I plan to start using it right away for another project that I'm working on, that I was going to use GSD to build that product. 

But I want to use Director instead so that I can be the first person testing it, and we can continue to improve it once it's being used in real life 
---

## Audience & Positioning Questions

### 4. Have you talked to other people like you?
You described yourself as a vibe coder. The biggest risk in building Director is assuming your experience is universal. Some questions to validate:
- Do other vibe coders find GSD's terminology confusing?
- Do they even use Claude Code, or are they using Cursor/Windsurf/ChatGPT?
- What's their biggest frustration with AI coding - is it really lack of structure, or something else (like debugging, deployment, or understanding what happened)?

**Why this matters:** If most vibe coders use Cursor (not Claude Code), Director's Claude Code plugin architecture is a mismatch.
**Answer**: I have not talked to other people like me. I gather that most non-coders are starting out with a platform like Cursor or directly coding in ChatGPT or Claude desktop making artifacts. That's exactly how I started. I don't know what the biggest frustration is for others. I know what it is for me as I built my current project, as the code base got bigger and bigger, I realized I was no longer capable of creating or adding to it without accidentally affecting other parts of it. 

And that's when I realized just building on without a map of some sort was detrimental and slowing down my progress. Then I started researching what are the proper ways to do this. That's where I discovered SPECT-driven development. And then I retroactively created PRD and documentation to help me. 

When I discovered GSD, I set it up as a brownfield project. I thought it was incredible to suddenly have these documents that helped me to visually understand my code base better. So I say all that because I don't really care about the other people at this point because selfishly I'm building this primarily for me. 

If I'm the only user of this new platform but it does work better than GSD, then it will have worked for me because I have dozens of projects in the pipeline that I need to build and I want to be able to build them as quickly and efficiently as possible. 

Now I have to assume there will for sure be at least a few others out there like me who don't even know that this is the answer that they are looking for, and they happen to be right at the same stage in their learning cycle with the development and coding that they're comfortable enough to start using Claude Code but still not experienced enough to know that they should probably be following specs. 

I think once we have this working effectively for me, then I can explore how to make it more user-friendly to help those non-coders make that initial jump or transition from a platform like Cursor to Claude Code. It's also worth mentioning here that the primary platform where I want this to work right now is Claude Code because that's where I work primarily. 

If everything that we're building is able to work in another platform like Cursor for example, then that's great. Then we'll make it available in Cursor or OpenCode or other places. But for now, if it only worked in Claude Code and it only works for me and it does achieve better results than GSD, then I'm satisfied. That to me would be an indication of a successful product 

### 5. Where does Director's audience currently live?
Marketing matters. Where would your target users discover Director?
- YouTube tutorials about vibe coding?
- Twitter/X AI development communities?
- Reddit r/ClaudeAI, r/LocalLLaMA, r/SideProject?
- ProductHunt launch?
- Claude Code plugin marketplace?

The answer affects naming, messaging, and where to invest effort.
**Answer**: I actually don't know because I haven't spent a lot of time in some of these places. I would guess in Reddit and YouTube, I watch a significant amount of YouTube tutorials about Vibe Coding, and that's where I've picked up on every single one of these repos that I gave initially as resources to compare.

My goal once this is functioning, I can do the marketing on my own. That is actually my core strength is marketing. I'll put it on the right marketplaces. I'll do a product hunt launch. I'll put it on all the relevant channels, and I will reach out to YouTube content creators to see if they want to promote it.

But that's all secondary in priority for me because, as I mentioned before, if nobody ever sees this or uses it, and I'm the only one who uses it, to me that would still be worth it. Because I need it to work for me to make my life better at shipping fast. But I do think it will spread once I start marketing it, assuming it's all working the way that we intend it to 

### 6. Should Director teach or just do?
There's a fundamental split in philosophy:
- **Teaching model**: Director explains what it's doing and why, helping users develop intuition ("I'm breaking your project into steps because large projects fail when you try to build everything at once")
- **Just-do-it model**: Director handles everything behind the scenes, user just answers questions and reviews results

Both are valid. Teaching builds long-term capability. Just-do-it reduces friction.

**My recommendation:** Start with "just do it" for actions, but provide "why" explanations for decisions that affect the user (like "I'm going to build the database before the login page because the login page needs somewhere to store user data").
**Answer**: I really like the idea of teaching as long as it's not long-winded or too cumbersome. Short recommendations that state like the example above of breaking it into steps (because projects fail when you try to build everything at once), that's good to know. A non-coder like me didn't know that prior to starting out with this.

But just because there might also be people who, after using this for a little while and they've learned, they no longer need the learning. If we add the teaching, it should be something that can be toggled on or off, whether that's in the settings, but it should be something that is optional for those who want it 

---

## Technical Architecture Questions

### 7. What about deployment?
Every tool I analyzed focuses on building code. None of them help with deployment. For vibe coders, getting code onto the internet is often the HARDEST part. Should Director have opinions about deployment?

Possibilities:
- Opinionated Vercel/Netlify integration
- Docker-based deployment skills
- "Ship to production" as a Director command
- Stay out of it (deployment is a separate concern)

**Why this matters:** If Director helps you build but not ship, the promise is only half-fulfilled.
**Answer**: this is a really good point, and I'm glad you brought it up because this was part of my learning curve when I built my first project. I had initially launched it on Vercel only to discover later, because of certain features that I was going to be building, that Railway might be a better option. I understand there are so many options: Railway, Vercel, Netlify, Hostinger, etc.

I do think we need to have a component about deployment, and maybe the best way to approach it is when the project is done or close to being done, the AI could ask, "Do you have plans or a vision for deployment and/or do you want to brainstorm that with me?" At that point, the AI could ask relevant questions to help steer the user in the right direction. If the user says, "Yes, I already have all that planned out," then it doesn't need to be a concern.

In fact, aside from deployment, in the initial planning, when a user adopts this for the first time and they haven't done any kind of planning yet, I think part of that initial onboarding that should happen should help the user understand what are their plans for deployment, what tech stack will they need, and it should guide and coach people through to help them know and maybe even give recommendations.

For example, I didn't realize that I was going to need authentication when I built my app. It was after we had already started and everything was moving forward that I moved the authentication from Supabase over to Clerk, and it simplified everything but did require a lot of refactoring. That brought up issues later because at the time I still wasn't using a thorough plan, and I forgot that some code was referring to Supabase for authentication and some newer code was referring to Clerk.

So when a new customer is being onboarded or a new user sets up a new project in the initial onboarding, those are things that we should take into account. Do you have a PRD? If not, let's do an interview, questions back and forth and then create a PRD. Okay, now you have a PRD and continue that process, right? To discover what are your plans for deployment, if you need suggestions, it should give suggestions and stuff like that.

Because again, we're assuming these are non-coders and they might need that assistance because they might not even know that that's going to be a factor at the end of the day 

### 8. What about existing projects?
You built a podcast web app with a RAG chatbot. Would you use Director on that existing project, or only for new projects?

GSD has strong brownfield support (/gsd:map-codebase). Director should decide early:
- **Greenfield only** (new projects): Simpler, but limits usefulness
- **Brownfield support** (existing projects): More complex, but serves real needs
- **Both** (recommended): Greenfield as primary workflow, brownfield as "import existing project"
**Answer**: yes, I would absolutely use Director on the existing project. In fact, as soon as it's ready, that will be the first place where I start using it and testing it. 

I had never heard of the concept of Greenfield versus Brownfield, and that was confusing to me. So using terminology like new versus existing is going to be really helpful. And if it is existing, having a thorough mapping and onboarding process will be great. In fact, when I installed GSD on my code base and it did that initial mapping, it gave me all kinds of insight into how my code base works that I was not aware of. It made me feel that much more confident about GSD.

So we need something equally or more thorough for Brownfield support. And then with Greenfield support, it should also help people think through their project well enough to have a good thorough PRD before proceeding. They might not know what that term means, but we could use other terminology like "let's iron out all the details of what this project requires" and then give them their requirement document and take that into account for next steps.

In GSD, I love the architecture file that shows a visual representation of the architecture with the mermaid charts. So we definitely do want to have support for existing and for new. I like your recommendation to have it for both, Greenfield as the primary and Brownfield as import existing project.

While we're talking about this topic, one thing that I noticed when I set up the Brownfield support and brought in my code base with GSD: once it mapped everything out, later I went in and made another change. I can't remember, it was a change to something in the architecture, and I made all those changes on accident outside of GSD, and I never thought to have an agent update the documentation to reflect the change in architecture. That's something that I want Director to be able to do well.

There should be an agent that anytime changes are done within the workflows verifies that if changes are needed in any of those relevant markdown files, then it does them. And there should maybe be a skill or a workflow that allows the developer to just say, "check and update all markdown files." That could be an agent that goes through and might find changes that the developer had done outside of the Director scope. Maybe they just prompted the AI to do a quick change and thought it wasn't a big deal, but it really was and it should have been documented in the Claude Markdown file or in one of the structural markdown files.

We need to take that into account because non-coders don't think strategically yet to remember to keep all of their documentation updated 

### 9. How does Director handle failure?
When the AI builds something wrong, what happens? This is the #1 frustration for vibe coders using AI agents. Current tools handle this differently:
- **GSD**: Verification loop spawns debugger agents, creates fix plans
- **Superpowers**: 4-phase systematic debugging
- **Autospec**: Retry logic with persistent state

For vibe coders, failure can feel personal ("I must have described it wrong") rather than systemic ("the AI misunderstood the requirement"). Director's failure handling needs to:
1. Explain what went wrong in plain language
2. Never blame the user
3. Suggest a clear next action
4. Offer to try again automatically
**Answer**: I agree with your assessment on how to handle failures. I think it needs to be something similar to what GSD does or superpowers. In fact, I hope you'll tell me what you think is the most effective way for a non-coder.

I like the idea of having Verification loop spawns debugger agents and then creates fixed plans, and then those plans are built out by coding agents. That seems to be a very user-friendly way of doing it. I don't want the debugging to feel complicated and scary for non-coders 

### 10. What about version control education?
Every tool in this space uses Git. Non-coders often don't understand Git. Director can either:
- **Abstract it away completely** (risky - user can't recover from problems)
- **Use it transparently** ("Director saved a checkpoint. If anything goes wrong, you can go back to this point.")
- **Teach it gradually** (introduce concepts as they become relevant)

**My recommendation:** Use Git transparently with checkpoint language. "I just saved your progress. You can type `/d undo` to go back to before this task."
**Answer**: I agree with your assessment. I think GitHub is mandatory. In fact, in the documentation, I'll probably do a tutorial and that will be one of the requirements to use this platform: to set up their repository with GitHub because anyone who's serious about building quality code is going to need to use GitHub anyway. So I do want to do that to allow people to learn along the way. I love the idea of giving checkpoint language so that people learn.

Now one concern I have, or a thought that I'd like you to think through: I have a couple of projects that I built using Obsidian. So I have an Obsidian vault and Claude Code running in it, and it manages my school assignments. All of my school stuff is done through Obsidian, and I don't use GitHub because I'm not doing code. So we need to take that into account.

If I'm using Director to create a platform for marketing or for school or something that doesn't even require any kind of coding (it's doing writing, for example), then the whole process of GitHub and version control is irrelevant. So I'm not sure how to handle that, but that is something to take into account. And I'd like your thoughts on that.

I think the default should be to use it transparently but also make it so that if the user is not using it, it doesn't break the platform. I hope that makes sense 
---

## Feature & Design Questions

### 11. What's the simplest possible Director experience?
If Director had only 3 commands, what would they be? This thought experiment reveals the core workflow:

My suggestion:
1. `/d start` - "What do you want to build?" (captures vision, creates relevant documentation, and gameplan)
2. `/d go` - "Here's what's next." (executes next task)
3. `/d check` - "Does this work?" (verification)

Everything else is enhancement on top of this core loop.
**Answer**: I like your recommendations. I also really like the “architect” approach of blueprint, build, and inspect. I think those might make more sense for the average non-coder. 

### 12. Should Director have pre-built templates?
Spec-Kit uses templates extensively. Should Director ship with templates for common project types?
- **Web App** (React + database + auth)
- **API/Backend** (Express/FastAPI + database)
- **Landing Page** (HTML/CSS + form)
- **Chrome Extension**
- **Automation Bot** (cron job + API integrations)

Templates reduce the cold-start problem ("I don't know where to begin") but add maintenance burden.
**Answer**: I don't like the idea of pre-built templates because everything is moving so fast in this space. I know that subconsciously I would be reluctant to use a template because I would have the fear that maybe this template is obsolete. 

I think I would prefer a thorough brainstorming session that creates the templates in the planning phase. That would actually feel highly relevant because it's the most up-to-date way to do it. I think the brainstorming feature from Superpowers is done really well and I've really enjoyed using that on my own projects.

So we need to have something that is equally good, if not better. And that brainstorming portion is where the AI can create the scaffolding or the template on the spot as needed. Otherwise, the user not only doesn't know where to begin, they wouldn't know which template to pick. 

I know that's something that I struggled with, I would have options, but I didn't know what I should even pick because I just didn't have enough information to feel confident to pick 

### 13. How does Director handle the "I changed my mind" problem?
Mid-project pivots are common. Non-coders especially tend to discover what they want by seeing what they don't want. Claude Task Master handles this with "update from task N onwards" (regenerate remaining tasks with new context).

Director needs a clear answer for: "I was building a todo app, but now I want it to also have a calendar. How do I update my gameplan?"
**Answer**: yes, this is a really good point and it's something I dealt with myself on my first big project that I built. At multiple milestones, I would shift directions to ship an entirely new feature or just restructure everything. For the most part, I don't think that's problematic, except when the spec documentation or the CLAUD Markdown file is not updated to reflect those changes. That's where I continually ran into trouble.

I think director should have a / command that addresses this. Maybe it's called "I changed my mind" or something like that, and that prompts a brainstorming session so that the AI can spawn an agent that asks all the relevant questions. Then it says, "Okay, let me take a look at the code base based on where we are and where you're trying to go now. Here's the best way to do it."

And then it comes up with a new plan that supersedes the old plan. It updates all the relevant documentation so that when the user jumps back in to keep going, the AI and the code base have full context awareness of the new direction that the person has taken.

another thing worth mentioning here, I don't know if it's already mentioned in the documentation somewhere, but when I'm working with GSD and I'm midway through a phase or a milestone, I'll suddenly have the idea of some new feature or I want to make a mental note for a to-do. I believe GSD has the command that allows you to create a new to-do, and I thought that was great. I like it.

The only problem for me is sometimes it's not necessarily a task, it's not a to-do list. It's just an idea. I would love to have an integration here where you could use "add idea" maybe, and then keep those saved somewhere. When you want to work on an idea, the AI can help the user to know if it's a simple task that's easy to do and doesn't require all the hard work, or the AI could analyze that idea and say, "Okay, to add this in, here's what it would take." It does the research and comes up with the elaborate plan, doing the normal workflow that we're using in this overall system.

That's just something that we need to take into account. Users will want to add tasks, but sometimes tasks are not real tasks, they're just ideas. The process of brainstorming the idea will either develop into a plan, or it just develops into a quick one-time task, or it develops into too much complexity, and the AI and the user together decide, "Okay, never mind. I don't want to implement that idea." So we need to take that into account  

### 14. What about testing?
None of the analyzed tools make testing accessible to vibe coders. They all assume the user understands what tests are and why they matter.

For vibe coders, "testing" should be:
- "Try logging in with a wrong password. What happens?" (acceptance testing in plain language)
- "I checked these 5 things and they all work" (verification checklist)
- NOT "run `npm test` and check for failing assertions"

Should Director enforce testing? Encourage it? Ignore it?
**Answer**: this is a good point because the idea of testing was virtually unknown to me when my code base started to get bigger and bigger. It was when I installed GSD that, in the initialization process with GSD, it asked about testing and I think it had some recommendations, that's how I discovered this particular URL and then I decided to add it to my code base.

But to be honest, I don't know how it works, if it works. So I don't know how to make testing accessible to non-coders. I think we for sure need to use acceptance testing in plain language with recommendations. You've added this feature now to make sure it works, go do this, this or that, and it gives them a list.

I know with GSD it'll build things and it'll reach sometimes the stage where it tells me to npm run dev and I usually just skip it and say approve because it feels too technical for me. I think it should be there as an option.

I don't know. What do you recommend considering the audience? I think we need to give them ideas of what they should be testing, but we should make it easy to not have to feel stuck and to make sure that they don't feel like, "Okay, all of this is too complicated. I'm just going to quit using Director."   
Maybe we can offer recommendations in the onboarding process? I ended up installing [https://vitest.dev/][1]to my codebase but I don’t know what it does or how it works,  and I’m not even sure if I’m using it correctly.

### 15. What metrics should Director track?
GSD tracks velocity, average duration, and trends. But for vibe coders, what metrics actually matter?

Possibilities:
- Tasks completed per session
- Goals completed per project
- Time from vision to first working feature
- Number of "redo" cycles (how often the AI had to fix its own work)
- API cost per goal/step/task

**Why this matters:** What you measure shapes behavior. If Director shows "tasks completed," users will optimize for small tasks. If it shows "goals completed," they'll focus on outcomes.
**Answer**: I regularly use GSD and I wasn't even aware that it was tracking anything. I agree that we want to have some form of measurement and I'm open to your suggestions here. I think API cost per goal step and task, that seems useful. 

I would like to know that from the perspective of a consumer, but outside of that, I don't think I would care all that much about tasks and goals. I do think it would be really cool to have a version of time from vision to first working feature, but in the context of if you were hiring this out prior to AI, this would have taken two weeks. 

I came across an app that did that and I remember it was really neat to know that thanks to AI, I built something in two hours that would have taken two weeks. So maybe something like that, but I don't think that's very important. And I don't know that we would be very accurate with it. So I'll leave that up to your discretion as well 
---

## Competitive & Market Questions

### 16. What if GSD adds a "beginner mode"?
GSD is the most comprehensive tool in this space. If they add simplified terminology and a visual dashboard, Director's differentiation narrows. What's Director's moat beyond accessibility?

Possible moats:
- Community and brand (director.cc, the "directing" philosophy)
- Deeper vibe coder UX research
- Integration with the broader solo builder ecosystem
- Visual-first design (if Dashboard is Phase 1)
- Opinionated project templates
**Answer**: I'm not sure about the idea of having a beginner mode. I think if anything, maybe we could have tips. You know how with some software, when you first start using it, it has tool tips or it has tips that show up, the first time you use this feature, it gives you a little tip and tells you "this is why you use onboarding" or "this is why we're splitting this into multiple steps instead of one." And after you've used it, then those tips go away. Maybe we could do something like that.

I don't want to bloat the system and make this too complicated. I think people will pick up on the process quickly. And I think the community and brand will be a moat, and I will be adding a broader ecosystem to it.

My plan is to have thorough documentation and possibly tutorial videos and maybe even a course that would take people through the whole process of building. They'll learn how to use the builder platform and also how to think like a coder. So I might have a course that's something like "coding for non-coders" and it'll teach them markdown, Claude Code, the basics of Cursor or the basics of deploying a website, things like that.

And maybe within that program or that course, there would be a module that's dedicated entirely to this particular platform, the Director platform. I think that's how I would tackle that.

I don't know if this is something that we need to be worried about because, like I said earlier, if this ends up being a product that only serves me, that will be worth it, even if nobody else ever saw it or used it 

### 17. What's the relationship with GSD?
Director draws heavily from GSD's architecture. Options:
- **Fork GSD** and simplify (fast to build, but maintenance burden)
- **Build on GSD** as a layer (use GSD internally, translate the interface)
- **Build independently** inspired by GSD patterns (more work, but full control)
- **Collaborate with GSD** (contribute the beginner layer upstream)
**Answer**: I think I would prefer to build independently since the terminology will be different and we're incorporating things from so many other systems. I think I would prefer to have full control of this as a new platform 

### 18. Should Director be agent-agnostic from the start?
OpenSpec supports 20+ AI tools. GSD is Claude Code only. Where should Director land?

Arguments for Claude Code only:
- Simpler to build and maintain
- Opus 4.6 features (agent teams, adaptive thinking) are Claude-specific
- Your audience uses Claude Code

Arguments for multi-agent:
- Larger addressable market
- Future-proofing
- Some vibe coders use Cursor, not Claude Code

**My recommendation:** Build for Claude Code first, but architect the skills layer to be portable (like OpenSpec's approach).
**Answer**: yes, I agree with your recommendation. I want to build this for ClaudeCode first, and a future feature implementation might be making it available on a different platform. 

But for now, the only one that truly matters to me is ClaudeCode, because that's where I'm using it and that's where the audience I'm targeting will be using it 

---

## Things You Might Not Be Thinking About

### 19. Accessibility and internationalization
If Director targets vibe coders globally, should it work in languages other than English? Should the plain-language explanations be localizable? 
**Answer**: for now, it should be English only, and we can entertain the possibility of other languages in the future 

### 20. Error recovery at scale
When a task fails and the AI spawns debugger agents, that can loop. What's the maximum number of retry cycles before Director says "I can't fix this automatically, here's what went wrong" and stops? GSD caps at 3 iterations. What's Director's limit? 
**Answer**: that's a good question. I think I'd be fine with 3 unless you think it's better to do more. I think I would be okay with anywhere between 3 to 5, but probably no more than 5 

### 21. The "blank page" problem
The hardest part for many vibe coders isn't the middle of a project - it's the very beginning. "What do you want to build?" is paralyzing when you have vague ideas. Should Director have an exploration/discovery phase before the formal brainstorming?
**Answer**: yes, it definitely should. I think it could be wrapped into the brainstorming process. So when somebody sets this up, that initial onboarding that would happen, assuming it's a new project, should gauge how much the non-coder has thought through or prepared for their particular project. 

From the perspective of a non-coder, when I first started using systems like this, I didn't know how much thought had to go into creating something. For example, I wanted to create an app for my daughter's soccer team to track how many times each player was substituted on the bench. And I did zero preparation. I just said, "Build an app that does X, Y, and Z." And once the AI finished it, then I realized what works and what doesn't, and then I would think about logic that I hadn't thought about.

So I think at the beginning of this whole process, it should always start with an interview. The onboarding process should assume that the non-coder has not fully thought through everything and it should ask questions to verify that. For example, once this is completed, "Have you already decided where you're going to deploy it?" If the answer is yes, then you move on. If the answer is no, then it might suggest deciding that or researching that before building, in case.

The non-coder might not know the difference of building out an HTML website versus a Next.js application and might not know that the hosting options are different based on that decision. So there definitely needs to be an initial phase that gauges what are you thinking, what are your ideas, and let's brainstorm those thoroughly. This should be a really good companion to brainstorm, to flesh out ideas and turn them into PRDs or whatever else is needed so that we give the non-coder the greatest chance of success 

### 22. Data privacy and cost transparency
Non-coders may not realize that their project descriptions and code are being sent to API providers. Should Director:
- Show cost tracking ("This session has used $0.47 in API calls")
- Warn about data sharing
- Support local/private LLMs for sensitive projects
**Answer**: I think it's important to make sure we don't scare anyone away from wanting to use it. A subtle warning in the documentation might warn them about data sharing, but I don't think we should overthink this.

If the user has gone through the effort to research and install this into their terminal so they can start using it with Claude Code, I think it's safe to assume they're willing to share that data and use it to build what they're trying to build. The coders who have thought through that more diligently have probably made plans of how they're building, and they're probably not even in the market for something quite like this.

I don't want to overthink this. I think mentioning it in the appropriate, subtle, relevant places is fine and that's it 

### 23. What happens when Director itself needs updating?
As an open-source plugin, Director will evolve. How do updates work? Auto-update? Manual? What if an update changes the workflow mid-project?
**Answer**: This is a good question. I think it should be manual, and when a user first installs this in the onboarding process, maybe the very first time that they're onboarding, it can remind them to check the website for the change log and give instructions on how to update it. I noticed GSD had a recent update that I didn't know about. I didn't even know it was something that needed to be updated, so I'm sure we'll encounter that.

I don't want it to happen automatically because I don't want to risk breaking something that's working for them. They should deliberately go in and update it. I think in the onboarding process we could even ask if you want to receive reminders for updates, enter your email, and maybe that adds them to a distribution list where I can notify them when new updates are coming out. I don't want to overthink that either.

But I do want them to be able to install this through NPX similar to how GSD does it. I'm new to that as well, so when the time comes I'll need help with that. 
---

*These questions don't all need answers today. They're designed to surface the decisions that will matter most as Director moves from brainstorm to PRD to implementation.*

[1]:	https://vitest.dev/