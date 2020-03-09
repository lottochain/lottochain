export default {
  namespaced: true,

  state: {
    articles: [
      {
        img: 'articles/article1a.png',
        altImg: 'articles/article1b.png',
        title: 'Instructions',
        slug: 'instructions',
        author: 'Lottochain Rules',
        p1: '<p>Each ticket costs $5 USD. You can purchase as many tickets you want, up to 30 tickets in a single transaction. e.g. 5 Tickets = $25 USD, 60 Tickets = $300 USD (divided into 2 transactions of 30 tickets ($150 USD) each). You can bet every day as well. Once you had choosen how many tickets you will purchase, the price converted in HTMLCoin will be shown and now you can send the correct amount from your wallet into Lottochain. You can always follow your transaction beeing processed on the block explorer link given upon transaction processing. Every 24 hours, every week and every month one ticket is drawn by the smart contract and the prize will be automatically sent to the winning wallet. Check below the percentage of distributed prizes through the month and join us. Each ticket purchased will give you 3 chances of winning.</p>',
        p2: '<p>Each ticket purchased will add its wallet to three different pots: Daily, Weekly and Monthly. <ul><li>On that same day, your wallet will be in the draw for 50% of all tickets purchased in that day.</li><li>On that same week, your wallet will be in the draw for 20% of all tickets purchased in that week.</li><li>On that same month, your wallet will be in the draw for 10% of all tickets purchased in that month.</li></ul></p><p>All that means that with one single ticket, you have 3 chances to win!</p>',
        p3: '<p>The Super Ticket is a HRC20 Token sold at htmlbunker.com that will give you the chance of winning 10% of the total amount of circulating HTMLCoin on Lottochain per month. For each single Ticket sold, Lottochain sends 10% of its funds to feed the Super Ticket Holders JackPot. Every month one Super Ticket is drawn and the prize is sent directly to the winners wallet, which will have the LOTTO Token retrieved from. Therefore, each LOTTO Token you hold will be valid until it is drawn. Eeach LOTTO token represents the certainty of winning a prize, once. Note that if you move the token between wallets, the system will track it and deliver the eventually drawn prize to the new wallet or owner. In other words, you will be able to negotiate the LOTTO token too, since there is a limited suply of 300,000 units, and lots of pairs to trade at HTMLBunker Exchange.</p>',
      },
      {
        img: 'articles/article2a.png',
        altImg: 'articles/article2b.png',
        title: 'Where to buy HTMLCOIN and Lottochain Tokens (LOTTO)',
        slug: 'htmlbunker',
        author: 'HTMLBunker HTMLCOIN Exchange',
        p1: '<p>The <b>HTMLBunker</b> (<a href="https://htmlbunker.com" target="_blank">htmlbunker.com</a>) is an exchange which is dedicated to the HTMLCoin community.</p>',
        p2: '<p>Over there all users are able to trade the most known crypto currencies and Fiat currencies, always relying on secured and safe processes.</p>',
        p3: '<p>The HRC20 token BUNK is used by HTMLBunker as a fee discount device, where all fees are reduced to 50% when charged in BUNK from the trading account.</p>',
      },
    ],
  },
}
