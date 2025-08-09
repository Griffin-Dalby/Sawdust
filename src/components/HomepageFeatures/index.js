import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

const FeatureList = [
  {
    title: 'Modern, expressive Syntax.',
    Svg: require('@site/static/img/undraw_docusaurus_mountain.svg').default,
    description: (
      <>
        <strong>Sawdust</strong> was built from the ground-up with developer experience and
        hassle-free usage in mind. A lot of the syntax you'll find in Sawdust
        is reminiscient of Node.JS.
      </>
    ),
  },
  {
    title: 'Efficient & Smart Abstractions',
    Svg: require('@site/static/img/undraw_docusaurus_tree.svg').default,
    description: (
      <>
        I've spent time testing and constantly evolving my implementations, integrating
        efficient practices in everyday actions. Internally, there is a lot of caching
        and lifetime tracking going on.
      </>
    ),
  },
  {
    title: 'Call To Contribute',
    Svg: require('@site/static/img/undraw_docusaurus_react.svg').default,
    description: (
      <>
        Have a great idea? Is a certain feature annoying you? Did you find a bug, or even
        a way to improve library efficiency? I'd love for you to help contribute! Either
        by genuinely contributing to <a href="#" onClick={()=>{window.open('https://github.com/Griffin-Dalby/Sawdust/','_blank')}}>this repo</a>, or <a href="#" onClick={()=>{window.open('https://github.com/Griffin-Dalby/Sawdust/issues','_blank')}}>filing a Issue report</a>
      </>
    ),
  },
];

function Feature({Svg, title, description}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} role="img" />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
