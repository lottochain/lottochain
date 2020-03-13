export default {
    namespaced: true,

    state: {
        featured: [],
        games: [{
                id: 1,
                name: 'Golden Chess',
                src: 'golden-chess',
                updated: 2,
                ready: false,
                content: false,
                p1: '<p>Golden Chess is going to be a great opportunity for all chess enthusiasts to earn crypto currencies while playing online!</p>',
                p2: '<p>You will be able to bet against others oponents in one of the most famous games around the world.</p>',
                p3: '<p>Htmlcoin Golden Chess will be launched at the second semester of 2020. Stay tuned!</p>',
            },
            {
                id: 2,
                name: 'Lottochain',
                src: 'lottochain-main-banner',
                updated: 1,
                ready: false,
                content: false,
                p1: '<p>Lottochain arose from our vision of a lottery where everyone can be sure that what separates them from a better life is solely their fate. The Smart Contracts of Althash Blockchain - Powered by HTMLCOIN - facilitate the operation of this vision, where anyone involved is able to verify the simplicity, the solidity and the fairness of the draws. Being implemented on the Htmlcoin network (Althash Platform), the Lottochain platform operates using Htmlcoin (HTML) as the official currency, meaning that the tickets and prizes values are based in HTMLCOIN/USD. Once the tickets are purchased, the funds are transferred to the main Lottochain Smart Contract, which is responsible for managing the total amount with different purposes:</p>',
                p2: '<p>50% for the daily prize address;<br>20% for the weekly prize address;<br>10% for the monthly prize address;<br>10% for the monthly super ticket holder prize address;<br>10% for Lottochain address (marketing, infrastructure, maintenance,legal support, fees)<br></p><p>The user addresses are stored and indexed in the Smart Contract, copied across different structures for each prize drawing periodicity (daily, weekly and monthly). Daily Prizes are drawn every day around 2 AM GMT. Weekly prizes, every Saturday around 2 AM GMT. Monthly and Super Ticket prizes, every 28th at 2 AM GMT.</p>',
                p3: '<p>The core of Lottochain (ticketing, prize drawing and funds transferring) resides in Htmlcoin Blockchain Smart Contracts, in what is called a Decentralized Application (DApp), developed with Solidity language. Each Smart Contract is an autonomous unity of processing running on the blockchain structure, hence immutable and auditable by anyone. Our Smart Contracts are being developed under all best-practice standards recommended by the platform for algorithm security and optimization, what can be verified since all codes are open-source and will be available on GitHub. They are responsible for ticket intake, drawing and funds transferences.</p><p>In order to have a fair drawing system, we need a source of randomness which cannot be achieved through Htmlcoin Smart Contracts, as they need to be deterministic, thus not being able to generate random numbers. The solution found was to refer to the Bitcoin and Htmlcoin Blockchains, from where we will take the hash of the first block mined after a pre-determined time in the future. In possession of that hash, we can then derive a number from it, which will be the index of the winning ticket. The prize transfer will happen immediately after the draw to the winning wallet.</p>',
            },
            {
                id: 3,
                name: 'Token Tower',
                src: 'token-tower',
                updated: 3,
                content: true,
                p1: '<p>Token Tower was built on the expertise of 3 great names with extensive expertise in crypto, software development and IoT markets, what results in cutting-edge solutions in Blockchain and financial development services.</p>',
                p2: '<p>We strive to cover all blockchain technology possibilities, from new blockchain startups, to seasoned and well funded venture-backed blockchain and cryptocurrency demands.</p>',
                p3: '<p>Blockchain is well-known for underpinning cryptocurrencies such as Bitcoin and other "altcoins", but it has the potential to transform various industries, including healthcare, logistics and supply chain, insurance, financial and many others.</p><p>In the early days of blockchain technology, many blockchain companies focused solely on (bitcoin) payment processing and exchange trading. As the wider scale of blockchain technology started to become more apparent, new blockchain companies started to emerge with use cases in industries other than just finance.</p><p>As a digital database containing information, such as records of financial or data transactions, that can be simultaneously used and shared within a large decentralized, publicly accessible network, Blockchain technology is now avaliable for all process that requires a high level of trust between two or more parts.</p><p>Visit us at www.tokentower.tech (coming soon)</p>',
            },
            {
                id: 4,
                name: 'HTML Poker',
                src: 'html-poker',
                updated: 2,
                ready: false,
                content: false,
                p1: '<p>Poker, the card game played in various forms throughout the world, in which a player must call the bet, raise the bet, or concede. Its popularity is greatest in North America, where it originated. It is played in private homes, in poker clubs, in casinos, and over the Internet. Poker has been called the national card game of the United States, and its play and jargon permeate American culture. Although countless variants of poker are described in the literature of the game, they all share certain essential features. A poker hand comprises five cards. The value of the hand is in inverse proportion to its mathematical frequency; that is, the more unusual the combination of cards, the higher the hand ranks. Players may bet that they have the best hand, and other players must either call (i.e., match) the bet or concede. Players may bluff by betting that they have the best hand when in fact they do not, and they may win by bluffing if players holding superior hands do not call the bet.</p>',
                p2: '<p>With Htmlcoin Poker you will be able to experience all of this but earning in crypto!</p>',
                p3: '<p>Htmlcoin Poker is beeing prepared for the end of 2020.</p>',
            },
            {
                id: 5,
                name: 'HTMLBunker',
                src: 'htmlbunker',
                updated: 3,
                content: true,
                p1: '<p>The <b>HTMLBunker</b> (<a href="https://htmlbunker.com" target="_blank">htmlbunker.com</a>) is the Htmlcoin partner exchange and Lottochain official exchange as well. It was built 6 months ago to be an exclusive HRC20 Token Wharehouse. The main goal is to create a stable and safe marketplace for all Htmlcoin tokens built on Althash Blockchain - the Htmlcoin DApps platform, and promote Htmlcoin pairs with lots of known crypto projects.</p>',
                p2: '<p>Htmlbunker strives to be in constant update and offers the fastest Htmlcoin exchange support nowadays. Its volume is still very low compared to other bigger exchanges, but good and reliable enough to purchase Htmlcoin to use as Lottochain Regular Tickets, as well as providing the SuperTicket Token (LOTTO) or sell your Lottochain prizes.</p>',
                p3: '<p>Register now at <a href="https://htmlbunker.com" target="_blank">https://htmlbunker.com</a>, purchase your Htmlcoin and lets start playing!</p>',
            },
            {
                id: 6,
                buyColor: '#3675A6',
                name: 'Purchase HTML',
                src: 'purchase-html',
                updated: 0,
                content: true,
                p1: '<p>The <b><a href="https://htmlbunker.com" target="_blank" style="color:gray">HTMLBunker</b></a> is the Htmlcoin partner exchange and Lottochain official exchange as well. It was built 6 months ago to be an exclusive HRC20 Token Wharehouse. The main goal is to create a stable and safe marketplace for all Htmlcoin tokens built on Althash Blockchain - the Htmlcoin dapps platform, and promote Htmlcoin pairs with lots of known crypto projects.</p>',
                p2: '<p>Htmlbunker strives to be in constant update and offers the fastest Htmlcoin exchange support nowadays. Its volume is still very low compared to other bigger exchanges, but good and reliable enough to purchase Htmlcoin to use as Lottochain Regular Tickets, as well as providing the SuperTicket Token (LOTTO) or sell your Lottochain prizes.</p>',
                p3: '<p>Register now at <a href="https://htmlbunker.com" target="_blank" style="color:gray">https://htmlbunker.com</a>, purchase your Htmlcoin and lets start playing!</p>',
            },
            {
                id: 7,
                buyColor: '#804C9D',
                name: 'Lottochain Features',
                src: 'lottochain-features',
                updated: 0,
                content: true,
                p1: '<p>Lottochain is a safe lottery implemented over smart contracts on Althash, the Htmlcoin Blockchain.</p>',
                p2: '<p>With a single ticket you have 3 chances to win daily, weekly and monthly prizes.<br>50% of all tickets are drawn daily amongst all people who bought tickets on that day. Similarly, 20% of all tickets purchased in a week are drawn amongst everyone who has purchased tickets in that week. Moreover, 10% of all tickets traded in the month are drawn amongst whoever bought tickets in that month.</p>',
                p3: '<p>Lottochain is a fair, auditable and decentralized lottery.</p><p>Smart Contracts Driven: In this way, anyone interested in circumventing the fairness of the lottery would have to be involved in the mining of specific blocks in two different networks at the same time, which would require an extremely high level of synchronism, a higher cost due to the loss of unpublished blocks bonuses and, mainly, greater processing power. In our platform, a function will search the HTML and BTC hashes of the first blocks published in the two networks after the predetermined time, and it will pass them to the Smart Contract responsible for the accomplishment of the prize draw and delivery to the winner. </p><p>The Smart Contract: Once the hashes are received, the Smart Contract uses them to derive the index that identifies the winning ticket in each one of the draws. The funds of the specific prize address (daily, weekly and monthly) are transferred to the address for the drawn ticket, discounting the transfer fees, maintaining the anonymity of the prize winner, since only their wallet address is known.</p><p>Once the hashes are received, the Smart Contract uses them to derive the index that identifies the winning ticket in each one of the draws. The funds of the specific prize (daily, weekly and monthly) are transferred to the address for the drawn ticket, discounting the transfer fees, maintaining the anonymity of the prize winner, since only their wallet address is known. Different prize draws (daily, weekly and monthly) will use hashes from blocks mined at predetermined but different times, in order to avoid an overlap of draws using the same blocks and, consequently, the same derived numbers (ie, the same winners).</p><p><b>The Scheduling</b>: Since it is a periodic execution based on predetermined schedules(daily, weekly and monthly), the current platform relies on a web server that executes calls of the drawing Smart Contracts within the established schedule. We do understand that as a point of centralization, however, there are no loopholes for external interferences since the blocks to be drawn will already have their pre - defined schedules. We will continue to work actively to find a fully decentralized solution, either through a maturing of the Smart Contracts development platform or through alternative reliable solutions.</p><p>Secure: The drawing and prize transfer processes run within Smart Contracts on the Althash blockchain, with open source code available on GitHub, what makes them thoroughly auditable. There is no trick, scam or Ponzi. No referrals as well. We will not encourage you to bother your friends or to become a spammer on internet groups. We do not need that kind of aggressive approach to growing. Our fair, rich and trustable platform is our credentials. The winner identity is safe.Your wallet is your ID and nobody will know who you are, not even Lottochain.The prize is immediately transferred to your wallet, and then you are free to do whatever you please with your money, with no concerns about anyone knowing about that. You may see other few crypto lottos around, and we indeed value their efforts and pioneering, however, Lottochain is here to propose a much better and more transparent way of giving you the chance you need to change your life.We offer you a simple, clear, fast solution, with fully open source codes and a fair dev fee, while others still remain tricking users with obscure whitepapers and unfair fees.</p>',
            },
            {
                id: 8,
                name: 'Rolling the Lucky',
                src: 'rolling-the-lucky',
                updated: 2,
                ready: false,
                content: false,
                p1: '<p>Usually, a crypto faucet is a game or platform that will give you satoshis in exchange for viewing ads or completing simple tasks.</p>',
                p2: '<p>Very common in the past, it was the best way of mass adoption and volume decentralization.</p>',
                p3: '<p>Htmlcoin Rolling the Lucky will distribute Htmlcoin for new users experiment our features and know more about this 6 years old crypto currency.</p>',
            },
            {
                id: 9,
                name: 'Lottochain News',
                src: 'lottochain-news',
                updated: 0,
                content: true,
                p1: '<p><b>Lottochain is released on the 10/03/2020</b></p>',
                p2: '<p>The Lottochain team is pleased to announce that Lottochain has been activated and tickets are already purchaseable.</p>',
                p3: '<p>Do not miss out and go get your tickets!</p>',
            },
            {
                id: 10,
                name: 'About HTMLCOIN',
                src: 'about-htmlcoin',
                updated: 3,
                content: true,
                p1: '<p>There are few crypto organizations that have walked the path of elaborate development in promoting blockchain usage and its mainstream adoption. While a few are doing their bit, Htmlcoin stands tall in this regard.</p>',
                p2: '<p>Htmlcoin was conceptualized in early 2013 and launched in 2014 as a cryptocurrency. Right from the start, it made its intentions clear regarding its purpose: to provide the world with an easy to use and comprehensive enterprise blockchain platform; by using state-of-the-art technology, the Htmlcoin Blockchain will equip businesses, entrepreneurs, and individuals with a fast and secure environment for all their products and services.</p>',
                p3: 'Htmlcoin is a hybrid of Bitcoin and Ethereum technologies, therefore, it is efficient, fast, and resilient. It is also maintained and regularly updated with the latest software updates from Bitcoin core upstream, as well as improved with features developed by its internal tech team and community.</p><p>Know more at <a href="https://htmlcoin.com" target="_blank" style="color:gray">htmlcoin.com</a></p>',
            },
        ],
    },

    getters: {
        featured: (state, getters) => {
            return getters.parsedGames.sort((a, b) => {
                if (a.updated < b.updated) return -1
                if (a.updated > b.updated) return 1
                return 0
            }).slice(0, 3)
        },
        parsedGames: state => {
            return state.games.map(game => ({
                ...game,
                bg: `games/${game.src}/bg.png`,
                bg2: `games/${game.src}/bg2.png`,
                logo: `games/${game.src}/logo.png`,
                avatar: `games/${game.src}/avatar.png`,
            })).sort((a, b) => {
                if (a.updated < b.updated) return -1
                if (a.updated > b.updated) return 1
                return 0
            })
        },
    },
}
